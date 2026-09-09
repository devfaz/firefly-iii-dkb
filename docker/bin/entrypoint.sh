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
	exec python3 /usr/local/bin/webhook_server.py
else
	source /usr/local/bin/process.sh
fi
