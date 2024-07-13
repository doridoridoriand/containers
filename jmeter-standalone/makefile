SHELL=/bin/bash

.PHONY: build
build:
	wget https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz
	tar zxvf apache-jmeter-5.6.3.tgz
	docker build -t jmeter-standalone:5.6.3 .
	rm -rf apache-jmeter*

.PHONY: release
release:
	bash release.sh
