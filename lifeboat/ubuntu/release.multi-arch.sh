#!/bin/bash

docker_ps_result=`docker ps 2>&1 > /dev/null`;

if [[ $docker_ps_result == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

unixtime=`date +%s`;

sudo docker buildx rm lifeboat-builder

sudo docker login;
cat ~/GH_TOKEN.txt | sudo docker login ghcr.io -u doridoridoriand --password-stdin;
sudo docker buildx create --name lifeboat-builder
sudo docker buildx use lifeboat-builder
sudo docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:latest
sudo docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:$unixtime
sudo docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest
sudo docker buildx build --push --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:$unixtime

