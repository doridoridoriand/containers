SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build --no-cache -t ubuntu-lifeboat:latest .

build-all:
	docker build --no-cache -t ubuntu-lifeboat:lunar-latest -f Dockerfile.amd64.lunar .
	docker build --no-cache -t ubuntu-lifeboat:jammy-latest -f Dockerfile.amd64.jammy .
	docker build --no-cache -t ubuntu-lifeboat:focal-latest -f Dockerfile.amd64.focal .


.PHONY: buildx
buildx:
	docker buildx create --name lifeboat-builder
	docker buildx use lifeboat-builder
	docker buildx build --platform=linux/arm64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-ubuntu:latest -f Dockerfile.non-amd64.lunar .
	docker buildx build --platform=linux/amd64 --tag doridoridoriand/lifeboat-ubuntu:latest -f Dockerfile.amd64.lunar .
	docker buildx rm lifeboat-builder

tag-current-unixtime: Dockerfile
	docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` ubuntu-lifeboat:`date +%s`

release:
	bash release.sh

releasex:
	bash release.multi-arch.sh

buildx-clean:
	docker buildx rm lifeboat-builder
