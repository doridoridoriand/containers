#!/usr/bin/env bash
DOCKER_PS_RESULT=$(docker ps > /dev/null 2>&1);
BUILDX_NAME=uuid-api-ruby-builder

docker buildx rm ${BUILDX_NAME}
docker buildx create --name ${BUILDX_NAME}
docker buildx use ${BUILDX_NAME}

# タグを置換してビルドする関数
build_with_tag() {
  replace_tag $1

  if [[ $DOCKER_PS_RESULT == *running?* ]]; then
    echo "ERROR: docker engine not running. Build failed." >&2;
    exit 1;
  fi

  GH_TOKEN=`cat ~/GH_TOKEN.txt`
  docker login;
  if ! echo $GH_TOKEN | docker login ghcr.io -u doridoridoriand --password-stdin; then
    echo "ERROR: Docker login failed." >&2;
    exit 1;
  fi

  # Docker Hub
  BUILD_SUCCESS=true
  if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/uuid-api-ruby:$1 --tag doridoridoriand/uuid-api-ruby:latest --tag doridoridoriand/uuid-api:ruby-$1 -f Dockerfile.$1 .; then
    BUILD_SUCCESS=false
  fi
  if [ "$BUILD_SUCCESS" = false ]; then
    echo "ERROR: Docker build failed for doridoridoriand/uuid-api-ruby:$1" >&2;
    exit 1;
  fi

  # GHCR
  BUILD_SUCCESS=true
  if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/uuid-api-ruby:$1 --tag ghcr.io/doridoridoriand/containers/uuid-api-ruby:latest -f Dockerfile.$1 .; then
    BUILD_SUCCESS=false
  fi
  if [ "$BUILD_SUCCESS" = false ]; then
    echo "ERROR: Docker build failed for ghcr.io/doridoridoriand/containers/uuid-api-ruby:$1" >&2;
    exit 1;
  fi

  rm Dockerfile.$1
}

# タグを置換する関数
replace_tag() {
    if ! sed "s/ruby:latest/ruby:$1/g" Dockerfile > Dockerfile.$1; then
        echo "ERROR: Failed to replace Ruby version tag in Dockerfile." >&2;
        exit 1;
    fi
}

# タグのリスト
tags=("3.2.2" "3.3.0" "3.3.4")

# タグごとにビルドを実行
for tag in "${tags[@]}"
do
    build_with_tag $tag
done

docker buildx rm ${BUILDX_NAME}
