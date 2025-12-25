#!/usr/bin/env zsh

set -eu

DOCKER_PS_RESULT=$(docker ps 2>/dev/null);
BUILDX_NAME=novnc-builder

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
# jammy
####################################################
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/novnc:jammy-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/novnc:jammy-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/novnc:jammy-latest \
                                                                                        --tag doridoridoriand/novnc:jammy-latest -f Dockerfile.jammy .

####################################################
# noble
####################################################
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/novnc:noble-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/novnc:noble-latest \
                                                                                        --tag ghcr.io/doridoridoriand/containers/novnc:noble-$unixtime \
                                                                                        --tag doridoridoriand/novnc:latest \
                                                                                        --tag ghcr.io/doridoridoriand/containers/novnc:latest \
                                                                                        --tag doridoridoriand/novnc:noble-latest -f Dockerfile.noble .

docker buildx rm ${BUILDX_NAME}
