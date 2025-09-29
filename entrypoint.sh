#!/bin/bash
set -e -o pipefail
# podman run --rm --pull=newer -it -v $HOME/.aqbanking/:/root/.aqbanking/ ghcr.io/devfaz/firefly-iii-dkb:latest /usr/local/bin/gencsv.sh

echo "Starting.."
if [ ! -r $HOME/.aqbanking/env ]; then
	echo "Missing ENV-File"
	exit 1
fi

cd $HOME/.aqbanking
source $HOME/.aqbanking/env

mkdir -pv csv
mkdir -pv archive
mkdir -pv balance

echo "Generating CSV.."
#
# generate new csv
gencsv.sh

set -x
# push csv to firefly-iii
if [ -n "${AUTOIMPORT_URL}" ]; then
	echo "Starting AUTOIMPORT.."
	for KTO in ${KTOS}; do
		if [ -e "import_config_${KTO}.json" ]; then
			find . -maxdepth 1 -name "${KTO}*.csv" | while read FILE; do
				if [ -n "${FILE}" && [ -e "${FILE}" ]; then
					mv -v "${FILE}" "${KTO}.csv"
				else
					echo "${FILE} not defined or unreadable"
					exit 1
				fi
				if [ $(wc -l <"${FILE}") -gt "1" ]; then
					echo "Starting auto-import of ${KTO}"
					autoimport.sh ${KTO}
					echo "---"
				fi
				mv -v "${KTO}.csv" "archive/$(date +%F)_$(basename $FILE)_${KTO}.csv"
			done
		fi
	done
fi
