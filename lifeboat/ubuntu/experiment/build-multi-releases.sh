#!/bin/bash

docker build --no-cache -t ubuntu-lifeboat:lunar-latest -f Dockerfile.amd64.lunar .
docker build --no-cache -t ubuntu-lifeboat:jammy-latest -f Dockerfile.amd64.jammy .
docker build --no-cache -t ubuntu-lifeboat:focal-latest -f Dockerfile.amd64.focal .
