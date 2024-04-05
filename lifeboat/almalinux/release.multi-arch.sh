#!/bin/bash

DOCKER_PS_RESULT=`docker ps 2>&1 > /dev/null`;

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo 'ERROR: docker engine not running. Build failed.' >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker buildx rm lifeboat-builder

docker login;
docker login ghcr.io -u doridoridoriand --password-stdin < ~/GH_TOKEN.txt;
docker buildx create --name lifeboat-builder
docker buildx use lifeboat-builder

##########################
# 8.8
##########################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-almalinux:8.8-$unixtime -f Dockerfile.8.8 \
                                                                                        --tag doridoridoriand/lifeboat-almalinux:8.8-latest -f Dockerfile.8.8
######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:8.8-$unixtime -f Dockerfile.8.8 \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:8.8-latest -f Dockerfile.8.8

##########################
# 9.2
##########################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-almalinux:9.2-$unixtime -f Dockerfile.9.2 \
                                                                                        --tag doridoridoriand/lifeboat-almalinux:9.2-latest -f Dockerfile.9.2 \
                                                                                        --tag doridoridoriand/lifeboat-almalinux:latest -f Dockerfile.9.2
######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:9.2-$unixtime -f Dockerfile.9.2 \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:9.2-latest -f Dockerfile.9.2 \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-almalinux:latest -f Dockerfile.9.2

docker buildx rm lifeboat-builder