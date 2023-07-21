#!/bin/bash

docker_ps_result=`docker ps 2>&1 > /dev/null`;

if [[ $docker_ps_result == *running?* ]]; then
  echo "ERROR: docker engine not running. Build failed." >&2;
  exit 1;
fi

unixtime=`date +%s`;

docker buildx create --name lifeboat-builder
docker buildx use lifeboat-builder
docker buildx build --load --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le -t ubuntu-lifeboat-multi-arch:latest .

docker tag `docker images ubuntu-lifeboat-multi-arch:latest --format "{{.ID}}"` doridoridoriand/lifeboat:ubuntu-multi-arch-latest;
docker tag `docker images ubuntu-lifeboat-multi-arch:latest --format "{{.ID}}"` doridoridoriand/lifeboat:ubuntu-multi-arch-$unixtime;

docker login;

docker push doridoridoriand/lifeboat:ubuntu-multi-arch-latest;
docker push doridoridoriand/lifeboat:ubuntu-multi-arch-$unixtime;

docker tag `docker images ubuntu-lifeboat-multi-arch:latest --format "{{.ID}}"` docker.pkg.github.com/doridoridoriand/containers/lifeboat:ubuntu-multi-arch-latest;
docker tag `docker images ubuntu-lifeboat-multi-arch:latest --format "{{.ID}}"` docker.pkg.github.com/doridoridoriand/containers/lifeboat:ubuntu-multi-arch-$unixtime;

cat ~/GH_TOKEN.txt | docker login docker.pkg.github.com -u doridoridoriand --password-stdin;

docker push docker.pkg.github.com/doridoridoriand/containers/lifeboat:ubuntu-multi-arch-latest;
docker push docker.pkg.github.com/doridoridoriand/containers/lifeboat:ubuntu-multi-arch-$unixtime;
