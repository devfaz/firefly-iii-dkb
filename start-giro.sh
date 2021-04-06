#!/bin/bash
set -e

mkdir -pv csv
podman run --rm -it -v $HOME/.aqbanking/:/root/.aqbanking/ aqbanking /usr/local/bin/gencsv.sh
mv $HOME/.aqbanking/*.csv csv/last.csv
./csv-convert.py --input csv/last.csv --output output.giro.csv
