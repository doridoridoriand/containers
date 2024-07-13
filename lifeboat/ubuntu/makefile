SHELL=/bin/bash

test-build: Dockerfile
	docker build --no-cache -t ubuntu-lifeboat:focal-latest -f Dockerfile.focal .
	docker build --no-cache -t ubuntu-lifeboat:jammy-latest -f Dockerfile.jammy .
	docker build --no-cache -t ubuntu-lifeboat:lunar-latest -f Dockerfile.lunar .
	docker build --no-cache -t ubuntu-lifeboat:noble-latest -f Dockerfile.noble .
	docker build --no-cache -t ubuntu-lifeboat:rolling-latest -f Dockerfile.rolling .

tag-current-unixtime: Dockerfile
	docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` ubuntu-lifeboat:`date +%s`

release:
	bash release.multi-arch.mac.sh

buildx-clean:
	docker buildx rm lifeboat-builder
