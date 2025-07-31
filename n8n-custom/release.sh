#!/usr/bin/env bash

set -eu

N8N_VERSION=${N8N_VERSION:-1.90.0}

# Ensure Docker is running
docker ps > /dev/null 2>&1 || { echo "Error: Docker is not running"; exit 1; }

# Configuration
BUILDX_NAME=n8n-container
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

cat Dockerfile | sed "s/VERSION_PLACEHOLDER/${N8N_VERSION}/g" > Dockerfile.${N8N_VERSION}

docker buildx build --push --platform=linux/arm64,linux/amd64 --tag ghcr.io/${GITHUB_USER}/containers/n8n:root-${N8N_VERSION} \
                                                              --tag ghcr.io/${GITHUB_USER}/containers/n8n:latest -f Dockerfile.${N8N_VERSION} .

rm Dockerfile.${N8N_VERSION}
