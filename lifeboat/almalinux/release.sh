#!/bin/bash

set -eu

DOCKER_PS_RESULT=`docker ps 2>&1 > /dev/null`;

if [[ $DOCKER_PS_RESULT == *running?* ]]; then
  echo 'ERROR: docker engine not running. Build failed.' >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker tag `docker images almalinux-lifeboat:9.2 --format "{{.ID}}"` doridoridoriand/lifeboat-almalinux:latest;
docker tag `docker images almalinux-lifeboat:9.2 --format "{{.ID}}"` doridoridoriand/lifeboat-almalinux:9.2-$unixtime;

docker login;

docker push doridoridoriand/lifeboat-almalinux:latest;
docker push doridoridoriand/lifeboat-almalinux:9.2-$unixtime;

docker tag `docker images almalinux-lifeboat:9.2 --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-almalinux:latest;
docker tag `docker images almalinux-lifeboat:9.2 --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-almalinux:9.2-$unixtime;

cat ~/GH_TOKEN.txt | docker login docker.pkg.github.com -u doridoridoriand --password-stdin;

docker push ghcr.io/doridoridoriand/containers/lifeboat-almalinux:latest;
docker push ghcr.io/doridoridoriand/containers/lifeboat-almalinux:9.2-$unixtime;
