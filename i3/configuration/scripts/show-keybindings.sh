#!/bin/bash
# Shows the custom i3 shortcuts in a searchable window, in the user's language (see locale.sh).
# A shortcut is listed when "bindsym" is preceded by a "# help: <English description>" comment,
# optionally followed by translations such as "# help-fr: <description en français>".

readonly I3_CONFIG_DIR="$HOME/.config/i3"
readonly CONFIG_FILES=("config" "workspaces.conf" "themes.conf" "custom.conf")
readonly WINDOW_WIDTH=640
readonly WINDOW_HEIGHT=480
# Every MSG_KEYBINDINGS_TITLE starts with "i3 — " so the i3 config floats the window in any language
# shellcheck source=locale.sh
source "$I3_CONFIG_DIR/scripts/locale.sh"

# Prints "key<TAB>description" for every annotated binding, translated when possible
extract_annotated_bindings() {
    local language="$1"
    local config_file
    for config_file in "${CONFIG_FILES[@]}"; do
        [ -f "$I3_CONFIG_DIR/$config_file" ] || continue
        awk -v translation_tag="# help-${language}:" '
            function strip_tag(line) { sub(/^[^:]*:[[:space:]]*/, "", line); return line }
            /^[[:space:]]*# help:/ { description = strip_tag($0); next }
            index($0, translation_tag) { translation = strip_tag($0); next }
            /^[[:space:]]*# help-[a-z]+:/ { next }
            description != "" && /^[[:space:]]*bindsym[[:space:]]/ {
                print $2 "\t" (translation != "" ? translation : description)
            }
            { description = ""; translation = "" }
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
    done < <(extract_annotated_bindings "$USER_LANGUAGE")

    zenity --list --title "$MSG_KEYBINDINGS_TITLE" --width "$WINDOW_WIDTH" --height "$WINDOW_HEIGHT" \
        --column "$MSG_KEYBINDINGS_SHORTCUT_COLUMN" --column "$MSG_KEYBINDINGS_ACTION_COLUMN" \
        "${zenity_rows[@]}" > /dev/null
}

main
