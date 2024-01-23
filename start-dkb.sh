#!/bin/bash
set -e

source $HOME/.aqbanking/env

mkdir -pv csv
mkdir -pv archive

echo "# WARNING !"
echo -e "#\n#\n"
echo "# This script is obsolete and will be removed."
echo "# Take a look into the README"
echo "# sleeping 5s"
sleep 5

#
# generate new csv
IMAGE=ghcr.io/devfaz/firefly-iii-dkb:latest
podman run --rm --pull=newer --userns=keep-id -it -v $HOME/.aqbanking/:/home/aqbanking/.aqbanking/ --entrypoint /usr/local/bin/gencsv.sh $IMAGE

echo "Moving generated csv into local directory"
find $HOME/.aqbanking/ -type f -name '*.csv' -print0 | xargs -0 -r -i mv -v {} .
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
