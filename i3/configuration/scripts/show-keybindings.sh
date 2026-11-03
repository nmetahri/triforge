#!/bin/bash
# Shows the custom i3 shortcuts in a searchable window, in the user's language.
# A shortcut is listed when "bindsym" is preceded by a "# help: <English description>" comment,
# optionally followed by translations such as "# help-fr: <description en français>".

readonly I3_CONFIG_DIR="$HOME/.config/i3"
readonly CONFIG_FILES=("config" "workspaces.conf" "themes.conf" "custom.conf")
readonly DEFAULT_LANGUAGE="en"
# Every title starts with "i3 — " so the i3 config can float the window in any language
declare -A WINDOW_TITLES=(["en"]="i3 — Shortcuts" ["fr"]="i3 — Raccourcis")
declare -A SHORTCUT_COLUMNS=(["en"]="Shortcut" ["fr"]="Raccourci")
readonly WINDOW_TITLES SHORTCUT_COLUMNS
readonly ACTION_COLUMN="Action"
readonly WINDOW_WIDTH=640
readonly WINDOW_HEIGHT=480

# "fr_FR.UTF-8" -> "fr"
user_language() {
    local locale="${LC_ALL:-${LC_MESSAGES:-${LANG:-$DEFAULT_LANGUAGE}}}"
    echo "${locale:0:2}"
}

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
    local language
    language="$(user_language)"
    [ -n "${WINDOW_TITLES[$language]}" ] || language="$DEFAULT_LANGUAGE"

    local zenity_rows=()
    local key description
    while IFS=$'\t' read -r key description; do
        zenity_rows+=("$(humanize_key "$key")" "$description")
    done < <(extract_annotated_bindings "$language")

    zenity --list --title "${WINDOW_TITLES[$language]}" --width "$WINDOW_WIDTH" --height "$WINDOW_HEIGHT" \
        --column "${SHORTCUT_COLUMNS[$language]}" --column "$ACTION_COLUMN" "${zenity_rows[@]}" > /dev/null
}

main
