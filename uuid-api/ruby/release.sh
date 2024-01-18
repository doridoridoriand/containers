#!/bin/bash
DOCKER_PS_RESULT=`docker ps > /dev/null 2>&1`;

#!/bin/bash

# タグを置換する関数
replace_tag() {
    sed -i "s/FROM ruby:[0-9.]\+/FROM ruby:$1/g" Dockerfile
}

# タグを置換してビルドする関数
build_with_tag() {
  replace_tag $1

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
  if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/uuid-api-ruby:$1 -f Dockerfile .; then
    BUILD_SUCCESS=false
  fi
  if [ "$BUILD_SUCCESS" = false ]; then
    echo "ERROR: Docker build failed for doridoridoriand/uuid-api-ruby:$1" >&2;
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
  if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/uuid-api-ruby:$1 -f Dockerfile .; then
    BUILD_SUCCESS=false
  fi
  if [ "$BUILD_SUCCESS" = false ]; then
    echo "ERROR: Docker build failed for ghcr.io/doridoridoriand/containers//uuid-api-ruby:$1" >&2;
    exit 1;
  fi

  BUILD_SUCCESS=true
  if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/uuid-api-ruby:latest -f Dockerfile .; then
    BUILD_SUCCESS=false
  fi
  if [ "$BUILD_SUCCESS" = false ]; then
    echo "ERROR: Docker build failed for ghcr.io/doridoridoriand/containers/uuid-api-ruby:latest" >&2;
    exit 1;
  fi

  docker buildx rm uuid-api-ruby-builder
}

# タグのリスト
tags=("2.4.2" "2.7.8" "3.2.2" "3.3.0")

# タグごとにビルドを実行
for tag in "${tags[@]}"
do
    build_with_tag $tag
done