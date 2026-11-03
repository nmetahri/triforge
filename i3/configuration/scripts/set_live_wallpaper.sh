#!/bin/bash

# --- Configuration ---
VIDEO_PATH="$1"
IPC_SOCKET="/tmp/mpv-wallpaper.sock"
# shellcheck source=locale.sh
source "$HOME/.config/i3/scripts/locale.sh"

if [ -z "$VIDEO_PATH" ]; then
    echo "$MSG_LIVE_WALLPAPER_USAGE"
    exit 1
fi

# 1. Tuer l'ancienne instance si elle existe
pkill -f "mpv.*--input-ipc-server=$IPC_SOCKET" && sleep 0.5

# 2. Lancer MPV en mode "fond d'écran"
# --wid=0 essaie de s'attacher à la fenêtre racine (root window) sur X11
mpv --wid=0 --loop --no-audio --vo=gpu --hwdec=auto \
    --input-ipc-server="$IPC_SOCKET" \
    --no-osc --no-osd-bar --cursor-autohide=always \
    "$VIDEO_PATH" &

# 3. Boucle d'économie d'énergie (Auto-pause)
while true; do
    # On récupère le nom de la fenêtre active
    # Sous i3, si on est sur le bureau vide, xdotool renvoie souvent "i3" ou rien
    WINDOW_NAME=$(xdotool getwindowfocus getwindowname 2>/dev/null)

    if [[ "$WINDOW_NAME" == "i3" || -z "$WINDOW_NAME" ]]; then
        # On est sur le bureau -> Play
        echo '{"command": ["set_property", "pause", false]}' | socat - "$IPC_SOCKET" 2>/dev/null
    else
        # Une fenêtre est active -> Pause pour économiser CPU/GPU
        echo '{"command": ["set_property", "pause", true]}' | socat - "$IPC_SOCKET" 2>/dev/null
    fi
    sleep 1 # Vérification toutes les secondes
done
