#!/bin/bash

set -eu

docker build --no-cache -f Dockerfile.leap -t opensuse-lifeboat:leap15.6-latest .
docker build --no-cache -f Dockerfile.leap16 -t opensuse-lifeboat:leap16-latest .
docker build --no-cache -f Dockerfile.tumbleweed -t opensuse-lifeboat:tumbleweed-latest .
