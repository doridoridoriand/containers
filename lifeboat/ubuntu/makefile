SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build --no-cache -t ubuntu-lifeboat:latest .

build-all:
	docker build --no-cache -t ubuntu-lifeboat:lunar-latest -f Dockerfile.lunar .
	docker build --no-cache -t ubuntu-lifeboat:jammy-latest -f Dockerfile.jammy .
	docker build --no-cache -t ubuntu-lifeboat:focal-latest -f Dockerfile.focal .

tag-current-unixtime: Dockerfile
	docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` ubuntu-lifeboat:`date +%s`

release:
	bash release.multi-arch.sh

buildx-clean:
	docker buildx rm lifeboat-builder
