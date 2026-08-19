#!/bin/bash
set -e -o pipefail

if [ "$1" = "webhook" ]; then
	echo "!"
	echo "! firefly-iii-dkb is now using a webhook system"
	echo "!"
	echo "! Use your browser to trigger the import: "
	echo
	echo http://localhost:8080/hooks/process
	echo
	webhook -hooks /etc/webhook/hooks.yaml
else
	source /usr/local/bin/process.sh
fi
