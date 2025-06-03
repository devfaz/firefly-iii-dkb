#!/bin/bash
set -e -o pipefail

IMAGE=${1:-ghcr.io/devfaz/firefly-iii-dkb:latest}
exec podman run --pull newer --rm -it --userns=keep-id -v $HOME/.aqbanking/:/home/aqbanking/.aqbanking/ "${IMAGE}"
