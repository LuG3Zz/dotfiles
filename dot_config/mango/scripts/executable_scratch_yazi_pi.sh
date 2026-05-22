#!/bin/bash
mmsg -d "toggle_named_scratchpad,yazi,none,alacritty --class yaziscratch -t yaziscratch -e tmux new-session -A -s yazi yazi"
alacritty -e pi
