#!/usr/bin/env zsh

set -eu

docker build -t doridoridoriand/novnc:noble-latest -f Dockerfile.noble .
docker run -d -p 6081:6081 -p 5901:5901 --name=novnc doridoridoriand/novnc:noble-latest