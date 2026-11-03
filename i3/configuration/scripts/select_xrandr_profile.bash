#!/bin/bash
# shellcheck source=locale.sh
source "$HOME/.config/i3/scripts/locale.sh"

CHOICE=$(autorandr --list | dmenu -i -p "$MSG_MONITOR_PROFILE_PROMPT")

if [ -n "$CHOICE" ]; then
    autorandr --load "$CHOICE"
fi
