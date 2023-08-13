#!/bin/bash
set -e -o pipefail

source $HOME/.aqbanking/env
KTO=$1

curl --location --request POST "${AUTOIMPORT_URL}" \
--header 'Accept: application/json' \
--form 'importable=@"./'${KTO}'.csv"' \
--form 'json=@"./import_config_'${KTO}'.json"'
