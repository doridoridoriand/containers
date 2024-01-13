#!/bin/bash
RUBY_VERSION=3.3.0;
DOCKER_PS_RESULT=`docker ps > /dev/null 2>&1`;

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

docker buildx rm uuid-api-ruby-builder
GH_TOKEN=`cat ~/GH_TOKEN.txt`
docker login;
if ! echo $GH_TOKEN | docker login ghcr.io -u doridoridoriand --password-stdin; then
  echo "ERROR: Docker login failed." >&2;
  exit 1;
fi

docker buildx create --name uuid-api-ruby-builder
docker buildx use uuid-api-ruby-builder

# Docker Hub
BUILD_SUCCESS=true
if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/uuid-api-ruby:$RUBY_VERSION -f Dockerfile .; then
  BUILD_SUCCESS=false
fi
if [ "$BUILD_SUCCESS" = false ]; then
  echo "ERROR: Docker build failed for doridoridoriand/uuid-api-ruby:$RUBY_VERSION" >&2;
  exit 1;
fi

BUILD_SUCCESS=true
if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/uuid-api-ruby:latest -f Dockerfile .; then
  BUILD_SUCCESS=false
fi
if [ "$BUILD_SUCCESS" = false ]; then
  echo "ERROR: Docker build failed for doridoridoriand/uuid-api-ruby:latest" >&2;
  exit 1;
fi

# GHCR
BUILD_SUCCESS=true
if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/doridoridoriand/uuid-api-ruby:$RUBY_VERSION -f Dockerfile .; then
  BUILD_SUCCESS=false
fi
if [ "$BUILD_SUCCESS" = false ]; then
  echo "ERROR: Docker build failed for ghcr.io/doridoridoriand/containers/doridoridoriand/uuid-api-ruby:$RUBY_VERSION" >&2;
  exit 1;
fi

BUILD_SUCCESS=true
if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/doridoridoriand/uuid-api-ruby:latest -f Dockerfile .; then
  BUILD_SUCCESS=false
fi
if [ "$BUILD_SUCCESS" = false ]; then
  echo "ERROR: Docker build failed for ghcr.io/doridoridoriand/containers/doridoridoriand/uuid-api-ruby:latest" >&2;
  exit 1;
fi

docker buildx rm uuid-api-ruby-builder