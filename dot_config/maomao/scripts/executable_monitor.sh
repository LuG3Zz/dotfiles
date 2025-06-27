#!/usr/bin/bash

# enable=$(wlr-randr --json | jq --arg name "eDP-1" '.[] | select(.name == $name) | .enabled')
enable=$(wlr-randr --json | jq --arg name "HDMI-A-2" '.[] | select(.name == $name) | .enabled')
if [ $enable == "true" ]; then
  wlr-randr --output HDMI-A-2 --off
  # wlr-randr --output eDP-1 --off
else
  wlr-randr --output HDMI-A-2 --on
  # wlr-randr --output eDP-1 --on
fi
