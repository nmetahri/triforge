#!/bin/bash
# shellcheck source=locale.sh
source "$HOME/.config/i3/scripts/locale.sh"
IMAGE=$(zenity --file-selection --title="$MSG_WALLPAPER_TITLE")
if [ -n "$IMAGE" ]; then
    feh --bg-scale "$IMAGE"
    echo "$IMAGE" > ~/.last_wallpaper
fi
