#!/bin/bash
set -e -o pipefail -u

TAG=$1

docker build -t $IMAGE:$TAG .
docker push $IMAGE:$TAG
docker tag $IMAGE:$TAG $IMAGE:latest
docker push $IMAGE:latest