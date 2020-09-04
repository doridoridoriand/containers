#!/bin/bash

unixtime=`date +%s`;

docker tag `docker images jmeter-standalone:latest --format "{{.ID}}"` docker.pkg.github.com/doridoridoriand/containers/jmeter-standalone:latest;
docker tag `docker images jmeter-standalone:latest --format "{{.ID}}"` docker.pkg.github.com/doridoridoriand/containers/jmeter-standalone:$unixtime;

cat ~/GH_TOKEN.txt | docker login docker.pkg.github.com -u doridoridoriand --password-stdin;

docker push docker.pkg.github.com/doridoridoriand/containers/jmeter-standalone:latest;
docker push docker.pkg.github.com/doridoridoriand/containers/jmeter-standalone:$unixtime;
