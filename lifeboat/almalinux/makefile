SHELL=/bin/bash

TAG_NAME = 0.0.1

test-build:
	docker build -t almalinux-lifeboat:8.8 -f Dockerfile.8.x .
	docker build -t almalinux-lifeboat:9.2 -f Dockerfile.9.x .

test-buildx:
	docker buildx create --name lifeboat-builder
	docker buildx use lifeboat-builder
	docker buildx build --platform=linux/arm64,linux/amd64,linux/s390x,linux/ppc64le --tag doridoridoriand/lifeboat-almalinux:latest .
	docker buildx rm lifeboat-builder

tag-current-unixtime:
	docker tag `docker images almalinux-lifeboat:latest --format "{{.ID}}"` almalinux-lifeboat:`date +%s`

release:
	bash release.multi-arch.sh

buildx-clean:
	docker buildx rm lifeboat-builder
