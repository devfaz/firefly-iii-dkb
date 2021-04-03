#!/bin/bash
set -e
WORKPATH="/root/.aqbanking"
source "$WORKPATH/env"

if [ -s ${WORKPATH}/TODATE ]
then
  FROMDATE=$( date +%Y%m%d -d "$( < ${WORKPATH}/TODATE ) + 1 day ")
  if [ "${FROMDATE}" = "$( date +%Y%m%d )" ]
  then
    echo "Nothing to do!"
    exit 0
  fi
else 
  FROMDATE=$( date +%Y%m%d -d '2 day ago' )
fi
TODATE="$( date +%Y%m%d -d '1 day ago' )"


echo "From $FROMDATE to $TODATE"
aqhbci-tool4 -P ${WORKPATH}/pinfile getaccounts -u 1

for KTO in $KTOS
do
  cd $WORKPATH
  aqbanking-cli -n -P ${WORKPATH}/pinfile request --account=${KTO} --fromdate=${FROMDATE} --todate=${TODATE} --transactions > /dev/shm/${KTO}.ctx
  aqbanking-cli export --exporter=csv -tt statement < /dev/shm/${KTO}.ctx > ${WORKPATH}/${KTO}-${FROMDATE}-${TODATE}.csv
  echo ${TODATE} > ${WORKPATH}/TODATE
done

echo "DONE"
