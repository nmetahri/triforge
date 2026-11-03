#!/bin/bash

# Script pour générer la configuration de la barre avec les couleurs du thème actif
BAR_GENERATED="$HOME/.config/i3/bar-generated.conf"
ACTIVE_THEME="$HOME/.config/i3/colors-active.conf"
# shellcheck source=locale.sh
source "$HOME/.config/i3/scripts/locale.sh"

# Créer le fichier bar-generated.conf avec la barre complète
cat > "$BAR_GENERATED" << 'EOF'
bar {
	font pango:Symbols Nerd Font Mono, Hack Nerd Font Mono 12, Exo2 15  
	status_command SCRIPT_DIR=~/.config/i3blocks/scripts i3blocks
	tray_output primary
	strip_workspace_numbers yes
	workspace_buttons yes
	binding_mode_indicator yes

	padding 4px 0
EOF

# Ajouter les couleurs du thème actif
if [ -f "$ACTIVE_THEME" ]; then
	cat "$ACTIVE_THEME" >> "$BAR_GENERATED"
else
	echo "$MSG_ACTIVE_THEME_NOT_FOUND" >&2
	exit 1
fi

# Fermer le bloc bar
echo "}" >> "$BAR_GENERATED"

