#!/bin/bash

set -eu

BUILDER_NAME=hammerdb-builder

if ! docker info > /dev/null 2>&1; then
  echo 'ERROR: docker engine not running. Build failed.' >&2;
  exit 1;
fi

docker login;
docker login ghcr.io -u doridoridoriand --password-stdin < ~/GH_TOKEN.txt;

if ! docker buildx create --name $BUILDER_NAME; then
  echo "Failed to create buildx builder" >&2
  exit 1
fi

if ! docker buildx use $BUILDER_NAME; then
  echo "Failed to use buildx builder" >&2
  docker buildx rm $BUILDER_NAME 2>/dev/null || true
  exit 1
fi

######### Docker Hub #########
if ! docker buildx build --push --platform=linux/arm64,linux/amd64 \
  --tag doridoridoriand/hammerdb:latest \
  --tag doridoridoriand/hammerdb:4.12 \
  -f hammer-db/Dockerfile hammer-db/; then
  echo "Failed to build and push Docker Hub images" >&2
fi

######### GitHub Packages #########
if ! docker buildx build --push --platform=linux/arm64,linux/amd64 \
  --tag ghcr.io/doridoridoriand/containers/hammerdb:latest \
  --tag ghcr.io/doridoridoriand/containers/hammerdb:4.12 \
  -f hammer-db/Dockerfile hammer-db/; then
  echo "Failed to build and push GitHub Packages images" >&2
fi

docker buildx rm hammerdb-builder 2>/dev/null || true