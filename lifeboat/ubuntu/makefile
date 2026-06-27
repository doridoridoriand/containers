SHELL=/bin/bash
DOCKER_HUB_SERVER=https://index.docker.io/v1/

.PHONY: docker-hub-auth-check
docker-hub-auth-check:
	@set -euo pipefail; \
	if [ ! -f "$$HOME/.docker/config.json" ]; then \
		exit 0; \
	fi; \
	helper=$$(sed -n 's/.*"credsStore"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$$HOME/.docker/config.json" | head -n 1); \
	if [ -z "$$helper" ]; then \
		exit 0; \
	fi; \
	helper_bin="docker-credential-$$helper"; \
	if ! command -v "$$helper_bin" >/dev/null 2>&1; then \
		echo "$$helper_bin is not installed, so Docker Hub credentials cannot be resolved." >&2; \
		exit 1; \
	fi; \
	if ! printf '%s\n' "$(DOCKER_HUB_SERVER)" | "$$helper_bin" get >/dev/null 2>&1; then \
		if [ "$$helper" = "osxkeychain" ] && [ -t 0 ] && [ -t 1 ]; then \
			echo "Unlocking macOS keychain for Docker Hub auth..."; \
			security -v unlock-keychain "$$HOME/Library/Keychains/login.keychain-db"; \
			printf '%s\n' "$(DOCKER_HUB_SERVER)" | "$$helper_bin" get >/dev/null; \
		else \
			echo "Docker Hub credentials are configured in $$helper, but this session cannot access them." >&2; \
			if [ "$$helper" = "osxkeychain" ]; then \
				echo 'Run `security -v unlock-keychain ~/Library/Keychains/login.keychain-db` in an interactive shell and retry.' >&2; \
			fi; \
			exit 1; \
		fi; \
	fi

.PHONY: test-build
test-build: docker-hub-auth-check
	DOCKER_BUILDKIT=1 docker build --no-cache -t ubuntu-lifeboat:focal-latest -f Dockerfile.focal .
	DOCKER_BUILDKIT=1 docker build --no-cache -t ubuntu-lifeboat:jammy-latest -f Dockerfile.jammy .
	DOCKER_BUILDKIT=1 docker build --no-cache -t ubuntu-lifeboat:lunar-latest -f Dockerfile.lunar .
	DOCKER_BUILDKIT=1 docker build --no-cache -t ubuntu-lifeboat:noble-latest -f Dockerfile.noble .
	DOCKER_BUILDKIT=1 docker build --no-cache -t ubuntu-lifeboat:rolling-latest -f Dockerfile.rolling .

.PHONY: tag-current-unixtime
tag-current-unixtime:
	docker tag `docker images ubuntu-lifeboat:latest --format "{{.ID}}"` ubuntu-lifeboat:`date +%s`

.PHONY: release
release:
	bash release.multi-arch.sh

.PHONY: buildx-clean
buildx-clean:
	docker buildx rm lifeboat-builder
