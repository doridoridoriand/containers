#!/bin/bash

DOCKER_PS_RESULT=`docker ps 2>&1 > /dev/null`;

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

unixtime=`date +%s`;

sudo docker buildx rm lifeboat-builder

sudo docker login;
cat ~/GH_TOKEN.txt | sudo docker login ghcr.io -u doridoridoriand --password-stdin;
sudo docker buildx create --name lifeboat-builder
sudo docker buildx use lifeboat-builder
##########################
# focal
##########################
######### Docker Hub #########
sudo docker buildx build --push --platform=linux/amd64 --tag doridoridoriand/lifeboat-ubuntu:focal-$unixtime -f Dockerfile.amd64.focal .
sudo docker buildx build --push --platform=linux/amd64 --tag doridoridoriand/lifeboat-ubuntu:focal-latest -f Dockerfile.amd64.focal .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:focal-$unixtime -f Dockerfile.non-amd64.focal .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:focal-latest -f Dockerfile.non-amd64.focal .
######### GitHub Packages #########
sudo docker buildx build --push --platform=linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-$unixtime -f Dockerfile.amd64.focal .
sudo docker buildx build --push --platform=linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-latest -f Dockerfile.amd64.focal .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-$unixtime -f Dockerfile.non-amd64.focal .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-latest -f Dockerfile.non-amd64.focal .

##########################
# jammy
##########################
######### Docker Hub #########
sudo docker buildx build --push --platform=linux/amd64 --tag doridoridoriand/lifeboat-ubuntu:jammy-$unixtime -f Dockerfile.amd64.jammy .
sudo docker buildx build --push --platform=linux/amd64 --tag doridoridoriand/lifeboat-ubuntu:jammy-latest -f Dockerfile.amd64.jammy .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:jammy-$unixtime -f Dockerfile.non-amd64.jammy .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:jammy-latest -f Dockerfile.non-amd64.jammy .
######### GitHub Packages #########
sudo docker buildx build --push --platform=linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-$unixtime -f Dockerfile.amd64.jammy .
sudo docker buildx build --push --platform=linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-latest -f Dockerfile.amd64.jammy .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-$unixtime -f Dockerfile.non-amd64.jammy .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-latest -f Dockerfile.non-amd64.jammy .

##########################
# lunar
##########################
######### Docker Hub #########
sudo docker buildx build --push --platform=linux/amd64 --tag doridoridoriand/lifeboat-ubuntu:lunar-$unixtime -f Dockerfile.amd64.lunar .
sudo docker buildx build --push --platform=linux/amd64 --tag doridoridoriand/lifeboat-ubuntu:lunar-latest -f Dockerfile.amd64.lunar .
sudo docker buildx build --push --platform=linux/amd64 --tag doridoridoriand/lifeboat-ubuntu:latest -f Dockerfile.amd64.lunar .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:lunar-$unixtime -f Dockerfile.non-amd64.lunar .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:lunar-latest -f Dockerfile.non-amd64.lunar .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:latest -f Dockerfile.non-amd64.lunar .
######### GitHub Packages #########
sudo docker buildx build --push --platform=linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-$unixtime -f Dockerfile.amd64.lunar .
sudo docker buildx build --push --platform=linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-latest -f Dockerfile.amd64.lunar .
sudo docker buildx build --push --platform=linux/amd64 --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest -f Dockerfile.amd64.lunar .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-$unixtime -f Dockerfile.non-amd64.lunar .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-latest -f Dockerfile.non-amd64.lunar .
sudo docker buildx build --push --platform=linux/arm64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest -f Dockerfile.non-amd64.lunar .
