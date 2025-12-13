SHELL=/bin/bash

.PHONY: test-build
test-build:
	docker build --no-cache -t opensuse-lifeboat:leap-latest -f Dockerfile.leap .
	docker build --no-cache -t opensuse-lifeboat:tumbleweed-latest -f Dockerfile.tumbleweed .

.PHONY: tag-current-unixtime
tag-current-unixtime:
	docker tag `docker images opensuse-lifeboat:latest --format "{{.ID}}"` opensuse-lifeboat:`date +%s`

.PHONY: release
release:
	bash release.multi-arch.sh

.PHONY: buildx-clean
buildx-clean:
	docker buildx rm lifeboat-builder
