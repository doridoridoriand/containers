#!/usr/bin/env zsh

set -eu

DOCKER_PS_RESULT=$(docker ps 2>/dev/null);
BUILDX_NAME=lifeboat-builder

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed.";
  exit 1;
fi

unixtime=$(date +%s);

BUILDX_ALREADY_EXISTS=$(docker buildx ls 2>&1 | grep ${BUILDX_NAME}) || true;

if [ -n "${BUILDX_ALREADY_EXISTS}" ]; then
    docker buildx rm ${BUILDX_NAME}
fi

docker login;
cat ~/GH_TOKEN.txt |  docker login ghcr.io -u doridoridoriand --password-stdin;
docker buildx create --name ${BUILDX_NAME}
docker buildx use ${BUILDX_NAME}
####################################################
# focal
####################################################
######### Docker Hub #########
nsc build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:focal-$unixtime \
                                                                              --tag doridoridoriand/lifeboat-ubuntu:focal-latest -f Dockerfile.focal .

######### GitHub Packages #########
nsc build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-$unixtime \
                                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-latest -f Dockerfile.focal .


####################################################
# jammy
####################################################
######### Docker Hub #########
nsc build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:jammy-$unixtime \
                                                                              --tag doridoridoriand/lifeboat-ubuntu:jammy-latest -f Dockerfile.jammy .

######### GitHub Packages #########
nsc build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-$unixtime \
                                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-latest -f Dockerfile.jammy .


####################################################
# noble
####################################################
######### Docker Hub #########
nsc build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:noble-$unixtime \
                                                                              --tag doridoridoriand/lifeboat-ubuntu:noble-latest \
                                                                              --tag doridoridoriand/lifeboat-ubuntu:latest -f Dockerfile.noble .

######### GitHub Packages #########
nsc build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:noble-$unixtime \
                                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:noble-latest \
                                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest -f Dockerfile.noble .

####################################################
# rolling
####################################################
######### Docker Hub #########
nsc build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:rolling-$unixtime \
                                                                              --tag doridoridoriand/lifeboat-ubuntu:rolling-latest -f Dockerfile.rolling .

######### GitHub Packages #########
nsc build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:rolling-$unixtime \
                                                                              --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:rolling-latest -f Dockerfile.rolling .

