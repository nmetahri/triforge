#!/bin/bash
# Shared helpers for triforge installers. Source this file, do not execute it.

readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

readonly SUPPORTED_DISTRIBUTIONS=("Ubuntu" "Debian GNU/Linux")

print_info() {
    echo -e "${COLOR_BLUE}$*${COLOR_RESET}"
}

print_success() {
    echo -e "${COLOR_GREEN}✓ $*${COLOR_RESET}"
}

print_warning() {
    echo -e "${COLOR_YELLOW}⚠ $*${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_RED}$*${COLOR_RESET}" >&2
}

require_sudo() {
    if [ -z "$SUDO_USER" ]; then
        print_error "This script must be run using sudo."
        exit 1
    fi
}

require_supported_distribution() {
    if [ ! -f /etc/os-release ]; then
        print_error "Cannot determine the Linux distribution."
        exit 1
    fi
    local distribution_name
    # shellcheck source=/dev/null
    distribution_name="$(. /etc/os-release && echo "$NAME")"
    local supported
    for supported in "${SUPPORTED_DISTRIBUTIONS[@]}"; do
        [ "$distribution_name" = "$supported" ] && return 0
    done
    print_error "This script is only compatible with Debian or Ubuntu (detected: $distribution_name)."
    exit 1
}

# Home directory of the user who invoked sudo (HOME points to /root under sudo)
target_user_home() {
    getent passwd "$SUDO_USER" | cut -d: -f6
}

is_systemd_running() {
    [ -d /run/systemd/system ]
}

run_as_target_user() {
    sudo -u "$SUDO_USER" -H "$@"
}

# Copies a file into the target user's home, owned by that user
install_user_file() {
    local source_path="$1"
    local destination_path="$2"
    run_as_target_user mkdir -p "$(dirname "$destination_path")"
    install -m 644 -o "$SUDO_USER" -g "$SUDO_USER" "$source_path" "$destination_path"
}

# Set ASSUME_YES=true to answer yes to every confirmation (non-interactive runs)
ask_confirmation() {
    local question="$1"
    local answer
    if [ "${ASSUME_YES:-false}" = true ]; then
        echo "$question (y/n): y (assumed)"
        return 0
    fi
    read -r -p "$question (y/n): " answer
    [ "$answer" = "y" ]
}

install_apt_packages() {
    print_info "Updating package lists..."
    apt-get update
    print_info "Installing packages: $*"
    apt-get install -y "$@"
    print_success "Packages installed"
}
