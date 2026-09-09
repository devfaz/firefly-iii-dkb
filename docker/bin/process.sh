#!/bin/bash
set -e -o pipefail -u

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

autoimport() {
	local KTO=$1
	local FILE=$2
	set -x
	curl --fail-with-body --location --request POST "${AUTOIMPORT_URL}" \
		--header 'Accept: application/json' \
		--form 'importable=@"'${FILE}'"' \
		--form 'json=@"./import_config_'${KTO}'.json"'
}

echo "Generating CSV.."
#
# generate new csv
gencsv.sh

# push csv to firefly-iii
if [ -n "${AUTOIMPORT_URL:-}" ]; then
	echo "Starting AUTOIMPORT.."
	for KTO in ${KTOS}; do
		if [ -e "import_config_${KTO}.json" ]; then
			find . -maxdepth 1 -type f -name "${KTO}*.csv" | while read FILE; do
				if [ -n "${FILE}" ] && [ -r "${FILE}" ]; then
					echo "${FILE} is readable"
				else
					echo "${FILE} not defined or unreadable"
					exit 1
				fi
				echo "Starting auto-import of ${KTO}"
				echo "---"
				if ! autoimport ${KTO} ${FILE}; then
					echo "auto-import - FAILED!"
					mv -v "${FILE}" "archive/${FILE}.failed.$(date +%s).csv"
					exit 1
				fi
				mv -v "${FILE}" "archive/$(date +%F)_$(basename $FILE)_${KTO}.csv"
				echo
			done
		fi
	done
fi
