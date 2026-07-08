#!/bin/bash
set -e -o pipefail -u

trap "read -p 'Hit ENTER to continue'" EXIT

IMAGE=${1:-ghcr.io/devfaz/firefly-iii-dkb:latest}

if which podman 1>/dev/null; then
	CMD="podman run --pull newer --rm -it --userns=keep-idi"
else
	CMD="docker run --pull always --rm -it -u $(id -u):$(id -g)"
fi

$CMD -v $HOME/.aqbanking/:/home/aqbanking/.aqbanking/ "${IMAGE}"
