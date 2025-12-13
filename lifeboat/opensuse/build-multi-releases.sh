#!/bin/bash

set -eu

docker build --no-cache -f Dockerfile.leap -t opensuse-lifeboat:leap-latest .
docker build --no-cache -f Dockerfile.tumbleweed -t opensuse-lifeboat:tumbleweed-latest .
