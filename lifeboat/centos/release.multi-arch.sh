#!/bin/bash

set -eu

docker ps >/dev/null 2>&1 || {
  echo 'ERROR: docker engine not running. Build failed.' >&2;
  exit 1;
}

BUILDX_NAME=lifeboat-builder
unixtime=$(date +%s);

BUILDX_ALREADY_EXISTS=$(docker buildx ls 2>&1 | grep ${BUILDX_NAME}) || true;

if [ -n "${BUILDX_ALREADY_EXISTS}" ]; then
    docker buildx rm ${BUILDX_NAME}
fi

docker login;
cat ~/GH_TOKEN.txt | docker login ghcr.io -u doridoridoriand --password-stdin;
docker buildx create --name ${BUILDX_NAME}
docker buildx use ${BUILDX_NAME}

##########################
# stream10
##########################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64 --tag doridoridoriand/lifeboat-centos:stream10-$unixtime \
                                                              --tag doridoridoriand/lifeboat-centos:stream10-latest \
                                                              --tag doridoridoriand/lifeboat-centos:latest -f Dockerfile .
######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-centos:stream10-$unixtime \
                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-centos:stream10-latest \
                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-centos:latest -f Dockerfile .
docker buildx rm ${BUILDX_NAME}
