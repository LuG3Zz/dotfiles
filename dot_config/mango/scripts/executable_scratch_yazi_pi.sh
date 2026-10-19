#!/bin/bash
mmsg -d "toggle_named_scratchpad,yazi,none,alacritty --class yaziscratch -t yaziscratch -e tmux new-session -A -s yazi yazi"
alacritty --class piscratch -t piscratch -e /home/brownlu/.local/bin/pi &
