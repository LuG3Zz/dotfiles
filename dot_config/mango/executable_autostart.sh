#!/bin/bash

set +e

# dms
dms run >/dev/null 2>&1 &

# ime
fcitx5 --replace -d >/dev/null 2>&1 &

# clipboard history
wl-paste --type text --watch cliphist store >/dev/null 2>&1 &
