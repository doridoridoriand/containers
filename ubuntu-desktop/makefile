SHELL=/bin/bash

TAG_NAME = 0.0.1

build: Dockerfile
	docker build -t ubuntu-desktop:latest .

run:
	docker run -it ubuntu-desktop:latest /bin/bash

tag-current-unixtime: Dockerfile
	docker tag `docker images centos-lifeboat:latest --format "{{.ID}}"` centos-lifeboat:`date +%s`

install: /pathj/to/binary
	mv /path/to/binary /usr/local/bin/binary

release:
	bash release.sh
