#!/usr/bin/env zsh

set -eu

VERSION=${VERSION:-5.6.3}

wget https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-${VERSION}.tgz
tar zxvf apache-jmeter-${VERSION}.tgz

docker build \
  -t jmeter-standalone:${VERSION} \
  -t ghcr.io/doridoridoriand/containers/jmeter-standalone:${VERSION} \
  -t ghcr.io/doridoridoriand/containers/jmeter-standalone:latest \
  .

cat ~/GH_TOKEN.txt | docker login ghcr.io -u doridoridoriand --password-stdin;

docker push ghcr.io/doridoridoriand/containers/jmeter-standalone:$VERSION;
docker push ghcr.io/doridoridoriand/containers/jmeter-standalone:latest;

rm -rf apache-jmeter-*