SHELL=/bin/bash

TAG_NAME = 0.0.1

.PHONY: build
build:
	docker build -t uuid-api-ruby:latest -f Dockerfile .

.PHONY: release
release:
	bash release.sh