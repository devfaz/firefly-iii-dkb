#!/bin/bash
set -e
cd $( dirname $0 )

mkdir -pv csv
podman build -t aqbanking --pull .
podman run --rm -it -v $HOME/.aqbanking/:/root/.aqbanking/ aqbanking /usr/local/bin/gencsv.sh
mv $HOME/.aqbanking/*.csv csv/
LAST_CSV=$( ls -t1 csv/1*.csv | head -n1 )
./csv-convert.py --input ${LAST_CSV} --output output.giro.csv
