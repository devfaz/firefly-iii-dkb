#!/bin/bash
set -e -o pipefail

exec podman run --pull newer --rm -it --userns=keep-id -v $HOME/.aqbanking/:/home/aqbanking/.aqbanking/ ghcr.io/devfaz/firefly-iii-dkb:latest
