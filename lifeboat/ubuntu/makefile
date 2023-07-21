SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build --no-cache -t ubuntu-lifeboat:latest .

buildx: Dockerfile
	docker buildx create --name lifeboat-builder
	docker buildx use lifeboat-builder
	docker buildx build --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le -t ubuntu-lifeboat-multi-arch:latest .
	docker buildx rm lifeboat-builder

tag-current-unixtime: Dockerfile
	docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` ubuntu-lifeboat:`date +%s`

release:
	bash release.sh

release-x:
	bash release.multi-arch.sh
