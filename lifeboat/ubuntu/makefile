SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build -t ubuntu-lifeboat:latest .

tag-current-unixtime: Dockerfile
	docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` ubuntu-lifeboat:`date +%s`

release:
	bash release.sh
