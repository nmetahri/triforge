#!/bin/bash
# Runs inside a fresh Debian/Ubuntu container as root: installs the given components
# like a real user would (sudo ./install), verifies them, then checks --update.
# Usage: tests/container_test.sh COMPONENT...

set -e

readonly TEST_USER="tester"
REPOSITORY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
readonly REPOSITORY_DIR
readonly COMPONENTS=("$@")

prepare_container() {
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y sudo python3
    useradd --create-home --shell /bin/bash "$TEST_USER"
    echo "$TEST_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$TEST_USER"
}

run_as_test_user() {
    sudo -u "$TEST_USER" -H "$@"
}

install_as_test_user() {
    run_as_test_user sudo DEBIAN_FRONTEND=noninteractive "$REPOSITORY_DIR/install" --yes "$@"
}

main() {
    prepare_container
    echo "===== Installing: ${COMPONENTS[*]} ====="
    install_as_test_user "${COMPONENTS[@]}"
    run_as_test_user "$REPOSITORY_DIR/tests/verify_install.sh" "${COMPONENTS[@]}"
    echo "===== Updating: ${COMPONENTS[*]} ====="
    install_as_test_user --update "${COMPONENTS[@]}"
    run_as_test_user "$REPOSITORY_DIR/tests/verify_install.sh" "${COMPONENTS[@]}"
}

main
