#!/bin/bash

DOCKER_PS_RESULT=`docker ps 2>&1 > /dev/null`;
BUIDX_NAME=lifeboat-builder

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker buildx rm ${BUIDX_NAME}

docker login;
cat ~/GH_TOKEN.txt |  docker login ghcr.io -u doridoridoriand --password-stdin;
docker buildx create --name ${BUIDX_NAME}
docker buildx use ${BUIDX_NAME}
####################################################
# focal
####################################################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:focal-$unixtime \
                                                                                        --tag doridoridoriand/lifeboat-ubuntu:focal-latest -f Dockerfile.focal .

######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-latest -f Dockerfile.focal .


####################################################
# jammy
####################################################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:jammy-$unixtime \
                                                                                        --tag doridoridoriand/lifeboat-ubuntu:jammy-latest -f Dockerfile.jammy .

######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-latest -f Dockerfile.jammy .


####################################################
# noble
####################################################
######### Docker Hub #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:noble-$unixtime \
                                                                                        --tag doridoridoriand/lifeboat-ubuntu:noble-latest \
                                                                                        --tag doridoridoriand/lifeboat-ubuntu:latest -f Dockerfile.noble .

######### GitHub Packages #########
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:noble-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:noble-latest \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest -f Dockerfile.noble .

docker buildx rm ${BUIDX_NAME}