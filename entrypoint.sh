#!/bin/bash
set -e -o pipefail
# podman run --rm --pull=newer -it -v $HOME/.aqbanking/:/root/.aqbanking/ ghcr.io/devfaz/firefly-iii-dkb:latest /usr/local/bin/gencsv.sh

if [ ! -r $HOME/.aqbanking/env ]; then
    echo "Missing ENV-File"
    exit 1
fi

cd $HOME/.aqbanking
source $HOME/.aqbanking/env

mkdir -pv csv
mkdir -pv archive
mkdir -pv balance

#
# generate new csv
gencsv.sh

# push csv to firefly-iii
if [ -n "${AUTOIMPORT_URL}" ]; then
    for KTO in ${KTOS}
    do
        if [ -e "import_config_${KTO}.json" ]; then
            FILE=$( find . -maxdepth 1 -name "${KTO}*.csv" )
            if [ -n "${FILE}" ] && [ -e "${FILE}" ] && [ "$( wc -l < "${FILE}" )" -gt "1" ]; then
                echo "Starting auto-import of ${KTO}"
                mv -v "${FILE}" "${KTO}.csv"
                autoimport.sh ${KTO}
                mv -v "${KTO}.csv" "archive/$( date +%F )_${KTO}.csv"
                echo "---"
            fi
        fi
    done
fi

