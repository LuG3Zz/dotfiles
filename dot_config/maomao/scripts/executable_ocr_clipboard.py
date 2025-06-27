#!/usr/bin/env python3

import subprocess
import base64
import json
import tempfile
import os
import sys
import requests  # type: ignore
import pyperclip  # type: ignore
from PIL import Image, UnidentifiedImageError  # type: ignore

OCR_API_URL = "http://172.17.0.2:5005/ocr"
CONNECT_TIMEOUT = 5  # seconds
REQUEST_TIMEOUT = 20  # seconds

# 跟踪由 get_image_from_clipboard 创建的临时文件
# 以确保即使后续 Pillow 识别失败也能进行清理。
_managed_temp_files = set()


def send_notification(summary, body="", urgency="normal", timeout=5000):
    """使用 dunstify 发送桌面通知。"""
    try:
        subprocess.run(
            ["dunstify", "-u", urgency, "-t", str(timeout), summary, body],
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        print("错误: 未找到 dunstify 命令。", file=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"发送通知错误: {e.stderr}", file=sys.stderr)


def _cleanup_temp_file(filepath):
    """清理指定的临时文件"""
    if filepath and filepath in _managed_temp_files:
        try:
            os.unlink(filepath)
            _managed_temp_files.remove(filepath)
        except OSError:
            pass  # 如果文件已不存在或无法访问，则忽略错误


def get_image_from_clipboard():
    """
    尝试从剪贴板获取图像数据，支持 X11 (xclip) 和 Wayland (wl-paste)。
    将其保存到临时文件，并返回文件路径和 Pillow 识别的格式。
    失败时返回 (None, None)。
    """
    is_wayland = os.environ.get("XDG_SESSION_TYPE") == "wayland"
    image_targets = ["image/png", "image/jpeg", "image/bmp", "image/tiff", "image/webp"]
    temp_file_path = None

    # 策略 1: 尝试特定的常见图像 MIME 类型
    for target_mime in image_targets:
        try:
            if is_wayland:
                cmd = ["wl-paste", "-t", target_mime]
                tool_name = "wl-paste"
            else:
                cmd = ["xclip", "-selection", "clipboard", "-t", target_mime, "-o"]
                tool_name = "xclip"

            process = subprocess.run(cmd, capture_output=True, check=False, timeout=5)

            if process.returncode == 0 and process.stdout:
                # 后缀只是给 NamedTemporaryFile 的提示，Pillow 会进行验证
                suffix = "." + target_mime.split("/")[-1]
                if suffix == ".jpeg":
                    suffix = ".jpg"  # Pillow 通常输出 'JPEG'

                with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp_f:
                    tmp_f.write(process.stdout)
                    temp_file_path = tmp_f.name
                    _managed_temp_files.add(temp_file_path)

                try:
                    with Image.open(temp_file_path) as img:
                        img_format = img.format.lower() if img.format else None
                        if img_format:
                            return temp_file_path, img_format
                        else:  # Pillow 未能识别，但我们获得了该类型的数据
                            # 使用请求的 MIME 类型的扩展名作为回退格式
                            return temp_file_path, target_mime.split("/")[-1]
                except UnidentifiedImageError:
                    _cleanup_temp_file(temp_file_path)  # 如果不是图像则清理
                    temp_file_path = None
                    continue  # 尝试下一个目标
                except Exception:  # 其他 Pillow 错误
                    _cleanup_temp_file(temp_file_path)
                    temp_file_path = None
                    continue

        except FileNotFoundError:
            send_notification("OCR 错误", f"未找到 {tool_name}。", urgency="critical")
            return None, None
        except subprocess.TimeoutExpired:
            send_notification(
                "OCR 错误", f"{tool_name} 获取 {target_mime} 超时。", urgency="normal"
            )
            continue  # 尝试下一个目标
        except Exception:  # pylint: disable=broad-except
            pass  # 静默尝试下一个目标或回退

    # 策略 2: 回退 (X11: 通用 xclip -o; Wayland: 列出类型并尝试 image/*)
    try:
        if is_wayland:
            # 对于 Wayland，列出可用类型并尝试获取图像类型
            try:
                list_proc = subprocess.run(
                    ["wl-paste", "--list-types"],
                    capture_output=True,
                    text=True,
                    check=True,
                    timeout=3,
                )
                available_types = list_proc.stdout.strip().split("\n")

                # 优先处理已知的图像类型，然后是任何 "image/*"
                sorted_available_types = [
                    t for t in available_types if t in image_targets
                ]
                for t in available_types:
                    if t.startswith("image/") and t not in sorted_available_types:
                        sorted_available_types.append(t)

                for mime_type in sorted_available_types:
                    try:
                        process = subprocess.run(
                            ["wl-paste", "-t", mime_type],
                            capture_output=True,
                            check=True,
                            timeout=5,
                        )
                        if process.stdout:
                            suffix = "." + mime_type.split("/")[-1]
                            if suffix == ".jpeg":
                                suffix = ".jpg"
                            with tempfile.NamedTemporaryFile(
                                delete=False, suffix=suffix
                            ) as tmp_f:
                                tmp_f.write(process.stdout)
                                temp_file_path = tmp_f.name
                                _managed_temp_files.add(temp_file_path)

                            try:
                                with Image.open(temp_file_path) as img:
                                    img_format = (
                                        img.format.lower() if img.format else None
                                    )
                                    if img_format:
                                        return temp_file_path, img_format
                                    else:  # Pillow 无法识别，但 wl-paste 提供了图像MIME类型的数据
                                        return temp_file_path, mime_type.split("/")[-1]
                            except UnidentifiedImageError:
                                _cleanup_temp_file(temp_file_path)
                                temp_file_path = None
                                continue  # 尝试下一个可用类型
                            except Exception:
                                _cleanup_temp_file(temp_file_path)
                                temp_file_path = None
                                continue
                    except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
                        continue  # 此类型可能无法粘贴或已超时
            except (
                FileNotFoundError,
                subprocess.CalledProcessError,
                subprocess.TimeoutExpired,
            ):
                if not any(
                    tf for tf in _managed_temp_files
                ):  # 仅当尚未找到图像时才通知
                    send_notification(
                        "OCR 错误",
                        "wl-paste --list-types 失败或未找到图像类型。",
                        urgency="normal",
                    )
                return None, None  # wl-paste 问题或没有合适的类型

        else:  # X11 回退
            process = subprocess.run(
                ["xclip", "-selection", "clipboard", "-o"],
                capture_output=True,
                check=True,
                timeout=5,
            )
            if process.stdout:
                with tempfile.NamedTemporaryFile(delete=False) as tmp_f:
                    tmp_f.write(process.stdout)
                    temp_file_path = tmp_f.name
                    _managed_temp_files.add(temp_file_path)
                try:
                    with Image.open(temp_file_path) as img:
                        img_format = img.format.lower() if img.format else None
                        if img_format:  # Pillow 必须在这里识别它
                            return temp_file_path, img_format
                        _cleanup_temp_file(temp_file_path)  # Pillow 无法识别
                        return None, None
                except UnidentifiedImageError:
                    _cleanup_temp_file(temp_file_path)
                    return None, None  # Pillow 无法识别的图像
    except FileNotFoundError:
        tool_name = "wl-paste" if is_wayland else "xclip"
        if not any(tf for tf in _managed_temp_files):
            send_notification(
                "OCR 错误", f"回退时未找到 {tool_name}。", urgency="critical"
            )
        return None, None
    except (
        subprocess.CalledProcessError,
        subprocess.TimeoutExpired,
    ):  # xclip 失败或剪贴板为空 / wl-paste 失败
        return None, None
    except Exception as e:  # pylint: disable=broad-except
        if not any(tf for tf in _managed_temp_files):
            send_notification(
                "OCR 错误", f"访问剪贴板错误 (回退): {e}", urgency="critical"
            )
        return None, None

    return None, None  # 如果所有尝试都失败


def main():
    tmp_image_path = None  # 初始化以确保在 finally 块中定义
    try:
        tmp_image_path, img_format = get_image_from_clipboard()

        if not tmp_image_path:
            send_notification(
                "OCR 错误", "剪贴板为空或不包含可识别的图片数据。", urgency="critical"
            )
            sys.exit(1)

        # 此时，get_image_from_clipboard 应该已返回有效的图像路径和格式
        # 但在这里用 Pillow 进行最终检查是一个很好的保障。
        if not img_format:  # 如果 get_image_from_clipboard 成功，理想情况下不应发生
            try:
                with Image.open(tmp_image_path) as img_check:
                    img_format = img_check.format.lower() if img_check.format else None
            except UnidentifiedImageError:
                send_notification(
                    "OCR 错误",
                    "剪贴板内容不是有效的图片格式 (Pillow 最终检查)。",
                    urgency="critical",
                )
                _cleanup_temp_file(tmp_image_path)
                sys.exit(1)
            except FileNotFoundError:  # 不应发生
                send_notification(
                    "OCR 错误", "临时图片文件丢失 (最终检查)。", urgency="critical"
                )
                sys.exit(1)

        if not img_format:  # 如果 Pillow 检查后仍无格式
            send_notification("OCR 错误", "无法识别图片格式。", urgency="critical")
            _cleanup_temp_file(tmp_image_path)
            sys.exit(1)

        try:
            with open(tmp_image_path, "rb") as image_file:
                base64_image_data = base64.b64encode(image_file.read()).decode("utf-8")
        except Exception as e:  # pylint: disable=broad-except
            send_notification(
                "OCR 错误", f"无法对图片进行 Base64 编码: {e}", urgency="critical"
            )
            sys.exit(1)
        # 此处没有 finally 来清理 tmp_image_path，它在 main 的 try 块末尾完成

        if not base64_image_data:
            send_notification("OCR 错误", "Base64 编码结果为空。", urgency="critical")
            sys.exit(1)

        json_payload = {"image": base64_image_data}

        send_notification("OCR", "正在处理图片...", urgency="low", timeout=2000)

        api_response_json = {}  # 初始化以扩大作用域
        try:
            response = requests.post(
                OCR_API_URL,
                json=json_payload,
                headers={"Content-Type": "application/json"},
                timeout=(CONNECT_TIMEOUT, REQUEST_TIMEOUT),
            )
            response.raise_for_status()
            api_response_json = response.json()

        except requests.exceptions.ConnectionError:
            send_notification(
                "OCR API 错误", "无法连接到 OCR 服务。", urgency="critical"
            )
            sys.exit(1)
        except requests.exceptions.Timeout:
            send_notification("OCR API 错误", "OCR 服务请求超时。", urgency="critical")
            sys.exit(1)
        except requests.exceptions.HTTPError as e:
            send_notification(
                "OCR API 错误",
                f"API 请求错误: {e.response.status_code}\n{e.response.text[:100]}",
                urgency="critical",
            )
            sys.exit(1)
        except requests.exceptions.JSONDecodeError:
            send_notification(
                "OCR API 错误", "无法解析 OCR 服务的 JSON 响应。", urgency="critical"
            )
            sys.exit(1)
        except Exception as e:  # pylint: disable=broad-except
            send_notification(
                "OCR API 错误", f"请求 API 时发生未知错误: {e}", urgency="critical"
            )
            sys.exit(1)

        extracted_texts = []
        if api_response_json.get("error"):
            extracted_texts.append(f"API 错误: {api_response_json['error']}")
        elif "results" in api_response_json and api_response_json["results"]:
            for result in api_response_json["results"]:
                extracted_texts.append(result.get("text", ""))
        else:
            extracted_texts.append("未识别到文本或结果为空。")

        processing_time_val = api_response_json.get("processing_time", "")
        final_text_output = "\n".join(filter(None, extracted_texts))

        if final_text_output.startswith("API 错误:") or final_text_output.startswith(
            "未识别到文本"
        ):
            send_notification("OCR 结果", final_text_output)
        else:
            try:
                pyperclip.copy(
                    final_text_output
                )  # Wayland下，pyperclip也需要wl-clipboard
                time_info = (
                    f"处理时间: {processing_time_val}s" if processing_time_val else ""
                )
                send_notification(
                    "OCR 完成", f"识别结果已复制到剪贴板。\n{time_info}".strip()
                )
            except pyperclip.PyperclipException as e:
                send_notification(
                    "OCR 错误",
                    f"无法复制到剪贴板: {e}\n结果:\n{final_text_output}",
                    urgency="critical",
                    timeout=10000,
                )
                print(f"OCR 结果:\n{final_text_output}", file=sys.stdout)

    finally:
        # 清理 get_image_from_clipboard 创建的任何临时文件
        if tmp_image_path:  # 特指成功获取到的这个文件路径
            _cleanup_temp_file(tmp_image_path)
        # 清理任何其他可能被遗弃的受管临时文件
        # 如果 _cleanup_temp_file 在 get_image_from_clipboard 中被正确调用，这里有点多余
        # 但作为最后的清扫。
        # 转换为列表以避免在 _cleanup_temp_file 修改集合时出现 "Set changed size during iteration"
        for f_path in list(_managed_temp_files):
            _cleanup_temp_file(f_path)


if __name__ == "__main__":
    # 告知用户潜在的 Wayland 依赖
    if os.environ.get("XDG_SESSION_TYPE") == "wayland":
        try:
            # 简单检查 wl-paste 是否存在且可执行
            subprocess.run(
                ["wl-paste", "--version"], capture_output=True, check=True, text=True
            )
        except (FileNotFoundError, subprocess.CalledProcessError):
            send_notification(
                "OCR 依赖警告",
                "未找到或无法运行 wl-clipboard (wl-paste)。在 Wayland 上从剪贴板进行图像 OCR 可能会失败。",
                urgency="normal",
                timeout=10000,
            )
            # 如果这是 Wayland 的硬性要求，可以选择在此处退出
            # sys.exit(1)

    main()
