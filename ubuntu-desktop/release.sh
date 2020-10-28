#!/bin/bash

unixtime=`date +%s`;

docker tag `docker images ubuntu-desktop:latest --format "{{.ID}}"` doridoridoriand/lifeboat:centos-latest;
docker tag `docker images ubuntu-desktop:latest --format "{{.ID}}"` doridoridoriand/lifeboat:centos-$unixtime;
docker login;
docker push doridoridoriand/lifeboat:centos-latest;
docker push doridoridoriand/lifeboat:centos-$unixtime;
