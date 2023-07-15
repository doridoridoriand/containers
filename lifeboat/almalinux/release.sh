#!/bin/bash

docker_ps_result=`docker ps 2>&1 > /dev/null`;

if [[ $docker_ps_result == *running?* ]]; then
  echo 'ERROR: docker engine not running. Build failed.' >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker tag `docker images almalinux-lifeboat:latest --format "{{.ID}}"` doridoridoriand/lifeboat:almalinux-latest;
docker tag `docker images almalinux-lifeboat:latest --format "{{.ID}}"` doridoridoriand/lifeboat:almalinux-$unixtime;

docker login;

docker push doridoridoriand/lifeboat:almalinux-latest;
docker push doridoridoriand/lifeboat:almalinux-$unixtime;

docker tag `docker images almalinux-lifeboat:latest --format "{{.ID}}"` docker.pkg.github.com/doridoridoriand/containers/lifeboat:almalinux-latest;
docker tag `docker images almalinux-lifeboat:latest --format "{{.ID}}"` docker.pkg.github.com/doridoridoriand/containers/lifeboat:almalinux-$unixtime;

cat ~/GH_TOKEN.txt | docker login docker.pkg.github.com -u doridoridoriand --password-stdin;

docker push docker.pkg.github.com/doridoridoriand/containers/lifeboat:almalinux-latest;
docker push docker.pkg.github.com/doridoridoriand/containers/lifeboat:almalinux-$unixtime;
