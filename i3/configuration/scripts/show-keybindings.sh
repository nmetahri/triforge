#!/bin/bash
# Shows the custom i3 shortcuts in a searchable window.
# A shortcut is listed when the line right above its "bindsym" is a "# help: <description>" comment.

readonly I3_CONFIG_DIR="$HOME/.config/i3"
readonly CONFIG_FILES=("config" "workspaces.conf" "themes.conf" "custom.conf")
readonly WINDOW_TITLE="Raccourcis i3"
readonly WINDOW_WIDTH=640
readonly WINDOW_HEIGHT=480

# Prints "key<TAB>description" for every annotated binding
extract_annotated_bindings() {
    local config_file
    for config_file in "${CONFIG_FILES[@]}"; do
        [ -f "$I3_CONFIG_DIR/$config_file" ] || continue
        awk '
            /^[[:space:]]*# help:/ { sub(/^[[:space:]]*# help:[[:space:]]*/, ""); description = $0; next }
            description != "" && /^[[:space:]]*bindsym[[:space:]]/ { print $2 "\t" description }
            { description = "" }
        ' "$I3_CONFIG_DIR/$config_file"
    done
}

# "$mod+Shift+comma" -> "Super + Shift + ,"
humanize_key() {
    # shellcheck disable=SC2016 # "$mod" is a literal i3 variable name, not a shell expansion
    echo "$1" | sed \
        -e 's/\$mod/Super/' \
        -e 's/\bcomma\b/,/' \
        -e 's/\bgreater\b/>/' \
        -e 's/\bless\b/</' \
        -e 's/+/ + /g'
}

main() {
    local zenity_rows=()
    local key description
    while IFS=$'\t' read -r key description; do
        zenity_rows+=("$(humanize_key "$key")" "$description")
    done < <(extract_annotated_bindings)

    zenity --list --title "$WINDOW_TITLE" --width "$WINDOW_WIDTH" --height "$WINDOW_HEIGHT" \
        --column "Raccourci" --column "Action" "${zenity_rows[@]}" > /dev/null
}

main
