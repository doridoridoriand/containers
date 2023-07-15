SHELL=/bin/bash

build: Dockerfile
	wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.2.tgz
	tar zxvf apache-jmeter-5.6.2.tgz
	docker build -t jmeter-standalone:latest .
	rm -rf apache-jmeter*

tag-current-unixtime: Dockerfile
	docker tag `docker images jmeter-standalone:latest --format "{{.ID}}"` jmeter-standalone:`date +%s`

release:
	bash release.sh
