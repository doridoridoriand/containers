SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build -t uuid-api-ruby:latest -f Dockerfile .

release:
	bash release.sh
