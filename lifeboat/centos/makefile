SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build -t centos-lifeboat:latest .

tag-current-unixtime: Dockerfile
	docker tag `docker images centos-lifeboat:latest --format "{{.ID}}"` centos-lifeboat:`date +%s`

release:
	bash release.sh
