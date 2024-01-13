#!/bin/bash

docker_ps_result=`docker ps 2>&1 > /dev/null`;

if [[ $docker_ps_result == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker buildx rm uuid-api-ruby-builder

docker login;
cat ~/GH_TOKEN.txt | docker login ghcr.io -u doridoridoriand --password-stdin;
docker buildx create --name uuid-api-ruby-builder
docker buildx use uuid-api-ruby-builder

# Docker Hub
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/uuid-api-ruby:$unixtime -f Dockerfile .
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/uuid-api-ruby:latest -f Dockerfile .
# GHCR
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/doridoridoriand/uuid-api-ruby:$unixtime -f Dockerfile .
docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/doridoridoriand/uuid-api-ruby:latest -f Dockerfile .

docker buildx rm uuid-api-ruby-builder