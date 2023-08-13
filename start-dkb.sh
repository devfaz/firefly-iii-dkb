#!/bin/bash
set -e

source $HOME/.aqbanking/env

mkdir -pv csv
mkdir -pv archive

#
# generate new csv
podman run --rm -it -v $HOME/.aqbanking/:/root/.aqbanking/ firefly-iii-dkb:latest /usr/local/bin/gencsv.sh

#
# convert csv
for FILE in $( find $HOME/.aqbanking/ -type f -name '*.csv' )
do
  FILENAME=$( basename $FILE )
  ./csv-convert.py --input $FILE --output $FILENAME
  rm -v $FILE
done

#
# push csv to firefly-iii
for KTO in ${KTOS}
do
  FILE=$( find . -name "${KTO}*" )
  if [ -n "${AUTOIMPORT_URL}" ] && [ -e "import_config_${KTO}.json" ] && [ -e "${FILE}" ]; then
    mv -v "${FILE}" "${KTO}.csv"
    ./autoimport.sh ${KTO}
    mv -v "${KTO}.csv" "archive/$( date +%F )_${KTO}.csv"
  fi
done