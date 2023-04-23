#!/bin/bash
set -e -o pipefail

source $HOME/.aqbanking/env

curl --location --request POST "${AUTOIMPORT_URL}" \
--header 'Accept: application/json' \
--form 'importable=@"./output.giro.csv"' \
--form 'json=@"./import_config_giro.json"'
