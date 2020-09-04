SHELL=/bin/bash

build: Dockerfile
	wget http://us.mirrors.quenda.co/apache//jmeter/binaries/apache-jmeter-5.3.tgz
	tar zxvf apache-jmeter-5.3.tgz
	docker build -t jmeter-standalone:latest .

tag-current-unixtime: Dockerfile
	docker tag `docker images jmeter-standalone:latest --format "{{.ID}}"` jmeter-standalone:`date +%s`

release:
	bash release.sh
