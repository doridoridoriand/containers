#!/usr/bin/env bash

set -eu

unixtime=$(date +%s);

docker tag $(docker images ubuntu-desktop:latest --format "{{.ID}}") doridoridoriand/ubuntu-desktop:latest;
docker tag $(docker images ubuntu-desktop:latest --format "{{.ID}}") doridoridoriand/ubuntu-desktop:$unixtime;
docker login;
docker push doridoridoriand/ubuntu-desktop:latest
docker push doridoridoriand/ubuntu-desktop:$unixtime
