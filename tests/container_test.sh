#!/bin/bash
# Runs inside a fresh Debian/Ubuntu container as root: installs the given components
# like a real user would (sudo ./install, or the one-line bootstrap), verifies them, then checks --update.
# Usage: tests/container_test.sh [--bootstrap] COMPONENT...

set -e

readonly TEST_USER="tester"
# Tag created in the repository copy so bootstrap installs the code under test, not GitHub's main.
# A tag rather than a branch: it exercises the release install path (TRIFORGE_REF=v1.0.0)
readonly BOOTSTRAP_TEST_TAG="v0.0.0-under-test"
REPOSITORY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
readonly REPOSITORY_DIR

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

install_with_installer() {
    run_as_test_user sudo DEBIAN_FRONTEND=noninteractive "$REPOSITORY_DIR/install" --yes "$@"
}

prepare_bootstrap_source() {
    # The test user clones this copy: it must own it, or git refuses it as a "dubious ownership" repository
    chown -R "$TEST_USER:$TEST_USER" "$REPOSITORY_DIR"
    run_as_test_user git -C "$REPOSITORY_DIR" tag --force "$BOOTSTRAP_TEST_TAG" HEAD
}

install_with_bootstrap() {
    run_as_test_user env TRIFORGE_REPOSITORY="$REPOSITORY_DIR" TRIFORGE_REF="$BOOTSTRAP_TEST_TAG" \
        bash "$REPOSITORY_DIR/bootstrap" --yes "$@"
}

main() {
    local install_command="install_with_installer"
    if [ "$1" = "--bootstrap" ]; then
        install_command="install_with_bootstrap"
        shift
    fi
    local components=("$@")

    prepare_container
    if [ "$install_command" = "install_with_bootstrap" ]; then
        apt-get install -y git
        prepare_bootstrap_source
    fi
    echo "===== Installing with ${install_command#install_with_}: ${components[*]} ====="
    "$install_command" "${components[@]}"
    run_as_test_user "$REPOSITORY_DIR/tests/verify_install.sh" "${components[@]}"
    echo "===== Updating with ${install_command#install_with_}: ${components[*]} ====="
    "$install_command" --update "${components[@]}"
    run_as_test_user "$REPOSITORY_DIR/tests/verify_install.sh" "${components[@]}"
}

main "$@"
