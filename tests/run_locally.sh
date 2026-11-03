#!/bin/bash
# Runs the container test locally with Docker, like the CI does.
# Usage: tests/run_locally.sh IMAGE COMPONENT...
# Example: tests/run_locally.sh ubuntu:24.04 tmux alacritty

set -e

REPOSITORY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
readonly REPOSITORY_DIR
readonly CONTAINER_REPOSITORY_DIR="/opt/triforge"

if [ $# -lt 2 ]; then
    echo "Usage: $0 IMAGE COMPONENT..." >&2
    exit 1
fi

image="$1"
shift

# Copy the repository so the container cannot modify the working tree
docker run --rm \
    --volume "${REPOSITORY_DIR}:/source:ro" \
    "$image" \
    bash -c "cp -r /source ${CONTAINER_REPOSITORY_DIR} && ${CONTAINER_REPOSITORY_DIR}/tests/container_test.sh $*"
