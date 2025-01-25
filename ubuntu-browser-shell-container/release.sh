#!/bin/bash

set -eu

# Ensure Docker is running
docker ps > /dev/null 2>&1 || { echo "Error: Docker is not running"; exit 1; }

# Configuration
BUILDX_NAME=browser-shell-container
UNIXTIME=$(date +%s)
GITHUB_USER=${GITHUB_USER:-doridoridoriand}

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

docker buildx build --push --platform=linux/arm64,linux/amd64 --tag ghcr.io/doridoridoriand/containers/ubuntu-shell-container:noble-$UNIXTIME \
                                                              --tag ghcr.io/doridoridoriand/containers/ubuntu-shell-container:noble-latest -f Dockerfile .