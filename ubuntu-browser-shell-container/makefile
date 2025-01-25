.PHONY: test-build
test-build:
	docker build -t ubuntu-shell-container:jammy-latest -f Dockerfile.jammy .
	docker build -t ubuntu-shell-container:noble-latest -f Dockerfile.noble .

.PHONY: release
release:
	./release.sh