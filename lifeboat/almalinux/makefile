SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build -t almalinux-lifeboat:latest .

tag-current-unixtime: Dockerfile
	docker tag `docker images almalinux-lifeboat:latest --format "{{.ID}}"` almalinux-lifeboat:`date +%s`

release:
	bash release.sh
