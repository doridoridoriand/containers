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
# leap
####################################################
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-opensuse:leap-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-opensuse:leap-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-opensuse:leap-latest \
                                                                                        --tag doridoridoriand/lifeboat-opensuse:leap-latest -f Dockerfile.leap .

####################################################
# tumbleweed
####################################################
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-opensuse:tumbleweed-$unixtime \
                                                                                        --tag doridoridoriand/lifeboat-opensuse:tumbleweed-latest \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-opensuse:tumbleweed-$unixtime \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-opensuse:tumbleweed-latest \
                                                                                        --tag doridoridoriand/lifeboat-opensuse:latest \
                                                                                        --tag ghcr.io/doridoridoriand/containers/lifeboat-opensuse:latest -f Dockerfile.tumbleweed .


docker buildx rm ${BUILDX_NAME}
