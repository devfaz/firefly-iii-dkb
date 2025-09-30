#!/bin/bash
set -e -o pipefail -u

IMAGE=${1:-ghcr.io/devfaz/firefly-iii-dkb:latest}
podman run --pull newer --rm -it --userns=keep-id -v $HOME/.aqbanking/:/home/aqbanking/.aqbanking/ "${IMAGE}"

read -p "Hit ENTER to continue"
