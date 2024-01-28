#!/bin/bash

DOCKER_PS_RESULT=`docker ps 2>&1 > /dev/null`;

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker buildx rm lifeboat-builder

docker login;
cat ~/GH_TOKEN.txt |  docker login ghcr.io -u doridoridoriand --password-stdin;
docker buildx create --name lifeboat-builder
docker buildx use lifeboat-builder
##########################
# focal
##########################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:focal-$unixtime \
                                                                                        --tag doridoridoriand/lifeboat-ubuntu:focal-latest -f Dockerfile.focal .

######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-latest -f Dockerfile.focal .


##########################
# jammy
##########################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:jammy-$unixtime \
                                                                                        --tag doridoridoriand/lifeboat-ubuntu:jammy-latest -f Dockerfile.jammy .

######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-latest -f Dockerfile.jammy .


##########################
# lunar
##########################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:lunar-$unixtime \
                                                                                        --tag doridoridoriand/lifeboat-ubuntu:lunar-latest \
                                                                                        --tag doridoridoriand/lifeboat-ubuntu:latest -f Dockerfile.lunar .

######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-latest \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest -f Dockerfile.lunar .

docker buildx rm lifeboat-builder