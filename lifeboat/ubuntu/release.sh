#!/usr/bin/env bash

set -eu

DOCKER_PS_RESULT=`docker ps 2>&1 > /dev/null`;

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

unixtime=`date +%s`;
docker login;
cat ~/GH_TOKEN.txt | docker login ghcr.io -u doridoridoriand --password-stdin;

##########################
# focal
##########################
docker tag `docker images ubuntu-lifeboat:focal-latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:focal-latest;
docker tag `docker images ubuntu-lifeboat:focal-latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:focal-$unixtime;

docker push doridoridoriand/lifeboat-ubuntu:focal-latest;
docker push doridoridoriand/lifeboat-ubuntu:focal-$unixtime;

docker tag `docker images ubuntu-lifeboat:focal-latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-latest;
docker tag `docker images ubuntu-lifeboat:focal-latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-$unixtime;

docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-latest;
docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:focal-$unixtime;

##########################
# jammy
##########################
docker tag `docker images ubuntu-lifeboat:jammy-latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:jammy-latest;
docker tag `docker images ubuntu-lifeboat:jammy-latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:jammy-$unixtime;

docker push doridoridoriand/lifeboat-ubuntu:jammy-latest;
docker push doridoridoriand/lifeboat-ubuntu:jammy-$unixtime;

docker tag `docker images ubuntu-lifeboat:jammy-latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-latest;
docker tag `docker images ubuntu-lifeboat:jammy-latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-$unixtime;

docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-latest;
docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:jammy-$unixtime;

##########################
# lunar
##########################
docker tag `docker images ubuntu-lifeboat:lunar-latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:latest;
docker tag `docker images ubuntu-lifeboat:lunar-latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:lunar-latest;
docker tag `docker images ubuntu-lifeboat:lunar-latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:lunar-$unixtime;

docker push doridoridoriand/lifeboat-ubuntu:latest;
docker push doridoridoriand/lifeboat-ubuntu:lunar-latest;
docker push doridoridoriand/lifeboat-ubuntu:lunar-$unixtime;

docker tag `docker images ubuntu-lifeboat:lunar-latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest;
docker tag `docker images ubuntu-lifeboat:lunar-latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-latest;
docker tag `docker images ubuntu-lifeboat:lunar-latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-$unixtime;

docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest;
docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-latest;
docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:lunar-$unixtime;
