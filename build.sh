#!/bin/bash
set -e
cd $( dirname $( readlink -f $0 ) )

podman build -t aqbanking --pull .
