#!/bin/bash

unixtime=`date +%s`;

docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` doridoridoriand/lifeboat:ubuntu-latest;
docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` doridoridoriand/lifeboat:ubuntu-$unixtime;
docker login;
docker push doridoridoriand/lifeboat:ubuntu-latest;
docker push doridoridoriand/lifeboat:ubuntu-$unixtime;
