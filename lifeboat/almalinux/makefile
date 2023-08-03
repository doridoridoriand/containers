SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build -t almalinux-lifeboat:8.8 -f Dockerfile.8.8 .
	docker build -t almalinux-lifeboat:9.2 -f Dockerfile.9.2 .

tag-current-unixtime: Dockerfile
	docker tag `docker images almalinux-lifeboat:latest --format "{{.ID}}"` almalinux-lifeboat:`date +%s`

release:
	bash release.sh
