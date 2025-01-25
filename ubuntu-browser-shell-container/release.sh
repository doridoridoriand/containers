#!/bin/bash

set -eu

DOCKER_PS_RESULT=`docker ps > /dev/null 2>&1`;
BUILDX_NAME=browser-shell-container
UNIXTIME=`date +%s`;

BUILDX_ALREADY_EXISTS=`docker buildx ls 2>&1 | grep ${BUILDX_NAME}` || true;

if [ -n "${BUILDX_ALREADY_EXISTS}" ]; then
    docker buildx rm ${BUILDX_NAME}
fi

docker buildx create --name ${BUILDX_NAME}
docker buildx use ${BUILDX_NAME}

# Use environment variable for token
if [ -z "${GITHUB_TOKEN:-}" ]; then
    if [ -f "${HOME}/GH_TOKEN.txt" ]; then
        GITHUB_TOKEN=$(cat "${HOME}/GH_TOKEN.txt")
    else
        echo "Error: Neither GITHUB_TOKEN environment variable nor GH_TOKEN.txt file found"
        exit 1
    fi
fi

echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_USER}" --password-stdin

docker buildx build --push --platform=linux/arm64,linux/amd64 --tag ghcr.io/doridoridoriand/containers/ubuntu-shell-container:jammy-$UNIXTIME \
                                                              --tag ghcr.io/doridoridoriand/containers/ubuntu-shell-container:jammy-latest -f Dockerfile .
