#!/usr/bin/env zsh

set -eu

BUILDX_NAME=boring-primenumber-builder

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker engine not running or unreachable. Build failed." >&2
  exit 1
fi

VERSION=0.0.2

BUILDX_ALREADY_EXISTS=$(docker buildx ls 2>&1 | grep ${BUILDX_NAME}) || true;

if [ -n "${BUILDX_ALREADY_EXISTS}" ]; then
    docker buildx rm ${BUILDX_NAME}
fi

docker login;
docker buildx create --name ${BUILDX_NAME}
docker buildx use ${BUILDX_NAME}

docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/waste_cpu_resource:2.7.8-$VERSION \
                                                                                        --tag doridoridoriand/waste_cpu_resource:latest -f Dockerfile .

docker buildx rm ${BUILDX_NAME}
