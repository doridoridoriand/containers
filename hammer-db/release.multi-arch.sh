#!/bin/bash

set -eu

if ! docker info > /dev/null 2>&1; then
  echo 'ERROR: docker engine not running. Build failed.' >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker login;
docker login ghcr.io -u doridoridoriand --password-stdin < ~/GH_TOKEN.txt;
docker buildx create --name hammerdb-builder
docker buildx use hammerdb-builder

######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64 --tag doridoridoriand/hammerdb:latest --tag doridoridoriand/hammerdb:4.12 -f Dockerfile .
######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64 --tag ghcr.io/doridoridoriand/containers/hammerdb:latest --tag ghcr.io/doridoridoriand/containers/hammerdb:4.12 -f Dockerfile .

docker buildx rm hammerdb-builder