#!/bin/bash
set -e -o pipefail -u

source $HOME/.aqbanking/env
KTO=$1

curl --fail-with-body --location --request POST "${AUTOIMPORT_URL}" \
	--header 'Accept: application/json' \
	--form 'importable=@"./'${KTO}'.csv"' \
	--form 'json=@"./import_config_'${KTO}'.json"'
