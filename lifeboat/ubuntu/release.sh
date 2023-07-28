#!/bin/bash

docker_ps_result=`docker ps 2>&1 > /dev/null`;

if [[ $docker_ps_result == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:latest;
docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` doridoridoriand/lifeboat-ubuntu:$unixtime;

docker login;

docker push doridoridoriand/lifeboat-ubuntu:latest;
docker push doridoridoriand/lifeboat-ubuntu:$unixtime;

docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest;
docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:$unixtime;

cat ~/GH_TOKEN.txt | docker login ghcr.io -u doridoridoriand --password-stdin;

docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:latest;
docker push ghcr.io/doridoridoriand/containers/lifeboat-ubuntu:$unixtime;
