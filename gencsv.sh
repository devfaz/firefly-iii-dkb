#!/bin/bash
set -e -u -o pipefail

WORKPATH="$HOME/.aqbanking"
source "$WORKPATH/env"

if [ -s ${WORKPATH}/TODATE ]; then
	FROMDATE=$(date +%Y%m%d -d "$(<${WORKPATH}/TODATE) + 1 day ")
	if [ "${FROMDATE}" = "$(date +%Y%m%d)" ]; then
		echo "Nothing to do!"
		exit 0
	fi
else
	FROMDATE=$(date +%Y%m%d -d '2 day ago')
fi
TODATE="$(date +%Y%m%d -d '1 day ago')"

if [ ! -f "${WORKPATH}/pinfile" ]; then
	echo "PINFILE missing"
	exit 1
fi

echo "From $FROMDATE to $TODATE"
aqhbci-tool4 -P ${WORKPATH}/pinfile getaccounts -u 1

cd $WORKPATH

for KTO in $KTOS; do
	aqbanking-cli --acceptvalidcerts -n -P ${WORKPATH}/pinfile request --account=${KTO} --fromdate=${FROMDATE} --todate=${TODATE} --transactions --balance >/dev/shm/${KTO}.ctx
	aqbanking-cli export --exporter=csv --profile-file=/opt/dkb-csv-export-profile.conf -tt statement </dev/shm/${KTO}.ctx >/dev/shm/${KTO}-${FROMDATE}-${TODATE}.csv
	balances.py /dev/shm/${KTO}.ctx | tee $WORKPATH/balance/${KTO}
done

#
# convert csv
for FILE in $(find /dev/shm/ -type f -name '*.csv'); do
	FILENAME=$(basename $FILE)
	csv-convert.py --input $FILE --output $WORKPATH/$FILENAME $CSV_CONVERT_ARGS
	rm -v $FILE
done

echo ${TODATE} >${WORKPATH}/TODATE

echo "DONE"
