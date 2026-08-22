#!/bin/bash
set -e -o pipefail -u

trap "read -p 'Hit ENTER to continue'" EXIT

MODE=${1:-legacy}
IMAGE=${2:-ghcr.io/devfaz/firefly-iii-dkb:latest}

if which podman 1>/dev/null; then
	CMD="podman run --pull newer --rm -it --userns=keep-idi -p8080:9000"
else
	CMD="docker run --pull always --rm -it -u $(id -u):$(id -g) -p8080:9000"
fi

if [ "$MODE" = "webhook" ]; then
	docker compose up --pull=always -d
else
	$CMD -v $HOME/.aqbanking/:/home/aqbanking/.aqbanking/ "${IMAGE}" "${MODE}"
fi
