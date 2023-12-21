#!/bin/bash
set -e

source $HOME/.aqbanking/env

mkdir -pv csv
mkdir -pv archive

#
# generate new csv
podman run --rm --pull=newer -it -v $HOME/.aqbanking/:/root/.aqbanking/ ghcr.io/devfaz/firefly-iii-dkb:latest /usr/local/bin/gencsv.sh

echo "Moving generated csv into local directory"
find $HOME/.aqbanking/ -type f -name '*.csv' -print0 | xargs -0 -r mv -v {} .
echo "---"
#
# push csv to firefly-iii
for KTO in ${KTOS}
do
  FILE=$( find . -name "${KTO}*" )
  if [ -n "${AUTOIMPORT_URL}" ] && [ -e "import_config_${KTO}.json" ] && [ -e "${FILE}" ]; then
    echo "Starting auto-import of ${KTO}"
    mv -v "${FILE}" "${KTO}.csv"
    ./autoimport.sh ${KTO}
    mv -v "${KTO}.csv" "archive/$( date +%F )_${KTO}.csv"
    echo "---"
  fi
done
