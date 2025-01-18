SHELL=/bin/bash

.PHONY: test-build
test-build:
	docker build --no-cache -t hammerdb:latest -f Dockerfile .

.PHONY: release
release:
	bash release.multi-arch.sh

.PHONY: buildx-clean
buildx-clean:
	docker buildx rm hammerdb-builder