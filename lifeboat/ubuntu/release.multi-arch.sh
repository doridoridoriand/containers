#!/usr/bin/env zsh

set -eu

# Check if Docker daemon is running
if ! docker ps >/dev/null 2>&1; then
  echo "ERROR: Docker engine not running. Build failed."
  exit 1
fi

# Get current timestamp
unixtime=$(date +%s)

# Setup buildx
BUILDX_NAME=lifeboat-builder
BUILDX_ALREADY_EXISTS=$(docker buildx ls 2>&1 | grep ${BUILDX_NAME}) || true

if [ -n "${BUILDX_ALREADY_EXISTS}" ]; then
    docker buildx rm ${BUILDX_NAME}
fi

# Login to Docker Hub and GitHub Container Registry
docker login
echo "$GH_TOKEN" | docker login ghcr.io -u doridoridoriand --password-stdin

# Create and use buildx builder instance
docker buildx create --name ${BUILDX_NAME}
docker buildx use ${BUILDX_NAME}

# Define release configurations
# Format: codename:Dockerfile:tag1:tag2:tag3:tag4:tag5:tag6
RELEASES=(
  "focal:Dockerfile.focal:doridoridoriand/lifeboat-ubuntu:focal-$unixtime:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-$unixtime:doridoridoriand/lifeboat-ubuntu:focal-latest:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-latest"
  "jammy:Dockerfile.jammy:doridoridoriand/lifeboat-ubuntu:jammy-$unixtime:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-$unixtime:doridoridoriand/lifeboat-ubuntu:jammy-latest:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-latest"
  "noble:Dockerfile.noble:doridoridoriand/lifeboat-ubuntu:noble-$unixtime:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:noble-$unixtime:doridoridoriand/lifeboat-ubuntu:noble-latest:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:noble-latest:doridoridoriand/lifeboat-ubuntu:latest:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest"
  "rolling:Dockerfile.rolling:doridoridoriand/lifeboat-ubuntu:rolling-$unixtime:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:rolling-$unixtime:doridoridoriand/lifeboat-ubuntu:rolling-latest:ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:rolling-latest"
)

# Process each release
for release in "${RELEASES[@]}"; do
  IFS=':' read -r codename dockerfile_tag docker_hub_tag1 github_packages_tag1 docker_hub_tag2 github_packages_tag2 docker_hub_tag3 github_packages_tag3 <<< "$release"
  
  echo "Building for $codename..."
  
  if ! docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le \
    --tag "$docker_hub_tag1" \
    --tag "$github_packages_tag1" \
    --tag "$docker_hub_tag2" \
    --tag "$github_packages_tag2" \
    --tag "$docker_hub_tag3" \
    --tag "$github_packages_tag3" \
    -f "$dockerfile_tag" .; then
    echo "Build failed for $codename. Cleaning up buildx context..."
    docker buildx rm ${BUILDX_NAME}
    exit 1
  fi
done

# Cleanup buildx
docker buildx rm ${BUILDX_NAME}
