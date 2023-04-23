#!/bin/bash
set -e

WORKPATH="$HOME/.aqbanking"
TODATE_PATH="$WORKPATH/TODATE_KK_BARC"

FETCH_FROMDATE=$( date +'%d.%m.%Y' -d '30 day ago' )

source $WORKPATH/env

if [ -s ${TODATE_PATH} ]
then
  FROMDATE=$( date +'%d.%m.%Y' -d "$( < ${TODATE_PATH} )" )
else
  FROMDATE=$( date +'%d.%m.%Y' -d '2 day ago' )
fi

if [ -z "$TODATE" ]
then
  TODATE="$( date +'%d.%m.%Y' -d '1 day ago' )"
  TODATE_SAFE="$( date +%F -d '1 day ago')"
fi

if [ "$FROMDATE" = "$TODATE" ]
then
  echo "Nothing to do"
  exit 0
fi

echo "csv-convert: $TODATE >= TODAY > $FROMDATE"
TMP=$( mktemp )
./csv-convert.py --input "$HOME/Downloads/Umsätze.xlsx" --output ${TMP} --date ${FROMDATE} --search 'Referenznummer' --date-filter-field 'Unnamed: 2'
mv -v "$HOME/Downloads/Umsätze.xlsx" $( mktemp )
echo "---"

echo "Output:"
cat ${TMP} | grep -A10000 Referenznummer > output.kk-barc.csv
cat output.kk-barc.csv
echo "---"

echo ${TODATE_SAFE} > ${TODATE_PATH}

