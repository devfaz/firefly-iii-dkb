#!/bin/bash
set -e

WORKPATH="$HOME/.aqbanking"
TODATE_PATH="$WORKPATH/TODATE_KK"

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

TMP=$( mktemp -d )

export PIN=$( grep PIN_ ~/.aqbanking/pinfile | cut -d= -f 2 | xargs )

echo "RAW dkb-visa:"
python dkb-visa/dkb.py --userid $DKB_USER --cardid $DKB_CARDID --output=${TMP}/kk.csv --raw --from-date="${FETCH_FROMDATE}" --to-date="${TODATE}"
echo "---"

echo "csv-convert: $TODATE >= TODAY > $FROMDATE"
./csv-convert.py --input ${TMP}/kk.csv --output output.kk.csv --date ${FROMDATE}
echo "---"

echo "Output:"
cat output.kk.csv
echo "---"
echo rm -v ${FILE}

echo ${TODATE_SAFE} > ${TODATE_PATH}

