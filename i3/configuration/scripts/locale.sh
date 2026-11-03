#!/bin/bash
# Loads user-facing messages (MSG_* variables) in the user's language. Source this file, do not execute it.
# English is loaded first, so a missing translation falls back to English.

readonly I3_LOCALES_DIR="$HOME/.config/i3/locales"
readonly DEFAULT_LANGUAGE="en"

# "fr_FR.UTF-8" -> "fr"
user_language() {
    local locale="${LC_ALL:-${LC_MESSAGES:-${LANG:-$DEFAULT_LANGUAGE}}}"
    echo "${locale:0:2}"
}

# shellcheck source=../locales/en.sh
source "$I3_LOCALES_DIR/$DEFAULT_LANGUAGE.sh"
USER_LANGUAGE="$(user_language)"
if [ -f "$I3_LOCALES_DIR/$USER_LANGUAGE.sh" ]; then
    # shellcheck source=/dev/null
    source "$I3_LOCALES_DIR/$USER_LANGUAGE.sh"
fi
