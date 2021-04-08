#!/bin/bash
set -e

WORKPATH="$HOME/.aqbanking"
TODATE_PATH="$WORKPATH/TODATE_KK"

source $WORKPATH/env

if [ -s ${TODATE_PATH} ]
then
  FROMDATE=$( date +'%d.%m.%Y' -d "$( < ${TODATE_PATH} ) + 1 day ")
  if [ "${FROMDATE}" = "$( date +'%d.%m.%Y' )" ]
  then
    echo "Nothing to do!"
    exit 0
  fi
else
  FROMDATE=$( date +'%d.%m.%Y' -d '2 day ago' )
fi
if [ -z "$TODATE" ]
then
  TODATE="$( date +'%d.%m.%Y' -d '1 day ago' )"
  TODATE_SAFE="$( date +%F -d '1 day ago')"
fi


TMP=$( mktemp -d )

export PIN=$( grep PIN_ ~/.aqbanking/pinfile | cut -d= -f 2 | xargs )

python dkb-visa/dkb.py --userid $DKB_USER --cardid $DKB_CARDID --output=${TMP}/kk.latin1.csv --raw --from-date="${FROMDATE}" --to-date="${TODATE}" 
iconv -f latin1 -t utf-8 ${TMP}/kk.latin1.csv > ${TMP}/kk.utf8.csv
./csv-convert.py --input ${TMP}/kk.utf8.csv --output output.kk.csv
echo rm -v ${FILE}

echo ${TODATE_SAFE} > ${TODATE_PATH}

