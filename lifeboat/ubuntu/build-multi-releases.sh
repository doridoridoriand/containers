#!/bin/bash

set -eu

docker build --no-cache -f Dockerfile.jammy -t ubuntu-lifeboat:latest .
docker build --no-cache -f Dockerfile.focal -t ubuntu-lifeboat:latest .
docker build --no-cache -f Dockerfile.lunar -t ubuntu-lifeboat:latest .
