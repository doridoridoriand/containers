#!/usr/bin/env bash
set -euo pipefail

export NAMESPACE=ollama
export IMAGE=ollama
tags=$(curl -s -H "Authorization: Bearer $(curl -s "https://auth.docker.io/token?scope=repository%3A${NAMESPACE}%2F${IMAGE}%3Apull&service=registry.docker.io" | jq -r '.token')" "https://registry-1.docker.io/v2/${NAMESPACE}/${IMAGE}/tags/list" | jq -r '.tags[]')
echo  "Available tags: ${tags[@]}"