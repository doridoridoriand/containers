SHELL=/bin/bash

test-build:
	docker build -t centos-lifeboat:stream10 -f Dockerfile .

test-buildx:
	docker buildx create --name lifeboat-builder
	docker buildx use lifeboat-builder
	docker buildx build --platform=linux/arm64,linux/amd64 --tag doridoridoriand/lifeboat-centos:stream10-latest .
	docker buildx rm lifeboat-builder

tag-current-unixtime:
	docker tag `docker images centos-lifeboat:latest --format "{{.ID}}"` centos-lifeboat:`date +%s`

release:
	bash release.multi-arch.sh

buildx-clean:
	docker buildx rm lifeboat-builder
