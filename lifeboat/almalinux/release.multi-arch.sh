#!/bin/bash

set -eu

DOCKER_PS_RESULT=$(docker ps 2>&1 > /dev/null);

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo 'ERROR: docker engine not running. Build failed.' >&2;
  exit 1;
fi

unixtime=$(date +%s);

BUILDX_ALREADY_EXISTS=$(docker buildx ls 2>&1 | grep ${BUILDX_NAME}) || true;

if [ -n "${BUILDX_ALREADY_EXISTS}" ]; then
    docker buildx rm ${BUILDX_NAME}
fi

docker login;
cat ~/GH_TOKEN.txt | docker login ghcr.io -u doridoridoriand --password-stdin;
docker buildx create --name lifeboat-builder
docker buildx use lifeboat-builder

##########################
# 8.10
##########################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64 --tag doridoridoriand/lifeboat-almalinux:8.10-$unixtime \
                                                              --tag doridoridoriand/lifeboat-almalinux:8.10-latest -f Dockerfile.8.x .
######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:8.10-$unixtime \
                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:8.10-latest -f Dockerfile.8.x .

##########################
# 9.4
##########################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64 --tag doridoridoriand/lifeboat-almalinux:9.4-$unixtime \
                                                              --tag doridoridoriand/lifeboat-almalinux:9.4-latest \
                                                              --tag doridoridoriand/lifeboat-almalinux:latest -f Dockerfile.9.x .
######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:9.4-$unixtime \
                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:9.4-latest \
                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:latest -f Dockerfile.9.x .

docker buildx rm lifeboat-builder