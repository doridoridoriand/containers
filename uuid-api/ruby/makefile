SHELL=/bin/bash

.PHONY: test-build
test-build:
	docker build --no-cache -t uuid-api-ruby:latest -f Dockerfile .

.PHONY: release
release:
	bash release.sh