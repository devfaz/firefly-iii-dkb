#!/bin/bash
set -e

source $HOME/.aqbanking/env

mkdir -pv csv
podman run --rm -it -v $HOME/.aqbanking/:/root/.aqbanking/ aqbanking /usr/local/bin/gencsv.sh
for FILE in $( find $HOME/.aqbanking/ -type f -name '*.csv' )
do
  mv -v $FILE csv/last.csv
  NEW=1
done

if [ -n "$NEW" ]
then
  ./csv-convert.py --input csv/last.csv --output output.giro.csv
fi

if [ -n "${AUTOIMPORT_URL}" ] && [ -e output.giro.csv ]; then
  ./autoimport.sh giro
  mkdir -pv archive
  mv -v output.giro.csv archive/$( date +%F )-output.giro.csv
fi