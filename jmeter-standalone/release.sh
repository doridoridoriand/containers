#!/bin/bash

unixtime=`date +%s`;

docker tag `docker images jmeter-standalone:latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/jmeter-standalone:latest;
docker tag `docker images jmeter-standalone:latest --format "{{.ID}}"` ghcr.io/doridoridoriand/containers/jmeter-standalone:$unixtime;

cat ~/GH_TOKEN.txt | docker login ghcr.io -u doridoridoriand --password-stdin;

docker push ghcr.io/doridoridoriand/containers/jmeter-standalone:latest;
docker push ghcr.io/doridoridoriand/containers/jmeter-standalone:$unixtime;
