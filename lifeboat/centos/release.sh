#!/bin/bash

unixtime=`date +%s`;

docker tag `docker images centos-lifeboat:latest --format "{{.ID}}"` doridoridoriand/lifeboat:centos-latest;
docker tag `docker images centos-lifeboat:latest --format "{{.ID}}"` doridoridoriand/lifeboat:centos-$unixtime;

docker login;

docker push doridoridoriand/lifeboat:centos-latest;
docker push doridoridoriand/lifeboat:centos-$unixtime;

docker tag `docker images centos-lifeboat:latest --format "{{.ID}}"` docker.pkg.github.com/doridoridoriand/containers/lifeboat:centos-latest;
docker tag `docker images centos-lifeboat:latest --format "{{.ID}}"` docker.pkg.github.com/doridoridoriand/containers/lifeboat:centos-$unixtime;

cat ~/GH_TOKEN.txt | docker login docker.pkg.github.com -u doridoridoriand --password-stdin;

docker push docker.pkg.github.com/doridoridoriand/containers/lifeboat:centos-latest;
docker push docker.pkg.github.com/doridoridoriand/containers/lifeboat:centos-$unixtime;
