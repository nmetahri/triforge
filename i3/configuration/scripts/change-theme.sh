#!/bin/bash

# Script pour changer les thèmes i3
THEMES_DIR="$HOME/.config/i3/themes"
ACTIVE_THEME="$HOME/.config/i3/colors-active.conf"
GENERATE_BAR="$HOME/.config/i3/scripts/generate-bar.sh"
# shellcheck source=locale.sh
source "$HOME/.config/i3/scripts/locale.sh"

# Lister les thèmes disponibles et les proposer via dmenu
THEME=$(ls "$THEMES_DIR"/*.conf | xargs -n1 basename | sed 's/\.conf$//' | dmenu -i -p "$MSG_THEME_PROMPT")

if [ -z "$THEME" ]; then
    exit 1
fi

# Créer un lien symbolique vers le thème choisi
THEME_FILE="$THEMES_DIR/$THEME.conf"

if [ -f "$THEME_FILE" ]; then
    # Supprimer l'ancien lien s'il existe
    rm -f "$ACTIVE_THEME"

    # Créer le nouveau lien symbolique
    ln -s "$THEME_FILE" "$ACTIVE_THEME"

    # Générer la barre avec les nouvelles couleurs
    "$GENERATE_BAR"

    # Recharger i3
    i3-msg reload
else
    echo "$MSG_THEME_NOT_FOUND $THEME_FILE" >&2
    exit 1
fi

