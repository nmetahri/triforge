#!/bin/bash
# Checks an installation made by ./install. Run as the user the components were installed for.
# Usage: tests/verify_install.sh COMPONENT...

readonly FORK_URL_PATTERN="nmetahri/tmux-resurrect"
readonly TMUX_PLUGINS=("tpm" "tmux-sensible" "tmux-resurrect" "tmux-continuum")
readonly VERIFY_TMUX_SOCKET="triforge-verify"

failure_count=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "  ✓ $description"
    else
        echo "  ✗ $description"
        failure_count=$((failure_count + 1))
    fi
}

is_owned_by_current_user() {
    [ -e "$1" ] && [ "$(stat -c %U "$1")" = "$(id -un)" ]
}

resurrect_uses_fork() {
    git -C "$HOME/.tmux/plugins/tmux-resurrect" remote get-url origin | grep -q "$FORK_URL_PATTERN"
}

tmux_config_loads() {
    tmux -L "$VERIFY_TMUX_SOCKET" -f "$HOME/.tmux.conf" new-session -d &&
        [ "$(tmux -L "$VERIFY_TMUX_SOCKET" show-options -gv @continuum-restore)" = "on" ]
    local status=$?
    tmux -L "$VERIFY_TMUX_SOCKET" kill-server
    return $status
}

has_hack_nerd_font() {
    fc-list | grep -q "Hack Nerd Font"
}

is_valid_toml() {
    python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$1"
}

# Reproduces what i3 does on first start (see themes.conf) so includes resolve
bootstrap_i3_theme() {
    ln -sfn "$HOME/.config/i3/themes/6-gruvbox.conf" "$HOME/.config/i3/colors-active.conf" &&
        "$HOME/.config/i3/scripts/generate-bar.sh"
}

verify_tmux() {
    echo "tmux:"
    check ".tmux.conf owned by $(id -un)" is_owned_by_current_user "$HOME/.tmux.conf"
    local plugin
    for plugin in "${TMUX_PLUGINS[@]}"; do
        check "plugin $plugin installed" test -d "$HOME/.tmux/plugins/$plugin"
    done
    check "tmux-resurrect cloned from the fork" resurrect_uses_fork
    check "configuration loads in tmux" tmux_config_loads
}

verify_alacritty() {
    echo "alacritty:"
    local config="$HOME/.config/alacritty/alacritty.toml"
    check "alacritty.toml owned by $(id -un)" is_owned_by_current_user "$config"
    check "alacritty.toml is valid TOML" is_valid_toml "$config"
    check "alacritty binary installed" command -v alacritty
}

verify_i3() {
    echo "i3:"
    check "i3 configuration owned by $(id -un)" is_owned_by_current_user "$HOME/.config/i3/config"
    check "i3blocks configuration copied" test -f "$HOME/.config/i3blocks/config"
    check "i3blocks built and installed" command -v i3blocks
    check "I3 + GNOME session registered" test -f /usr/share/xsessions/i3-gnome.desktop
    check "picom compositor installed" command -v picom
    check "Hack Nerd Font available" has_hack_nerd_font
    check "first-start theme bootstrap succeeds" bootstrap_i3_theme
    check "i3 configuration is valid (i3 -C)" i3 -C -c "$HOME/.config/i3/config"
}

main() {
    local component
    for component in "$@"; do
        "verify_${component}"
    done
    if [ "$failure_count" -gt 0 ]; then
        echo "$failure_count check(s) failed"
        exit 1
    fi
    echo "All checks passed"
}

main "$@"
