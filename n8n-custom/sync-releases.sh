#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
RELEASE_SCRIPT_DEFAULT="${SCRIPT_DIR}/release.sh"
START_VERSION="1.123.27"
END_VERSION=""
DRY_RUN=0
REFRESH_LATEST=1
LOG_DIR=""
UPSTREAM_REPO="n8nio/n8n"
GITHUB_USER="${GITHUB_USER:-doridoridoriand}"
GHCR_IMAGE="ghcr.io/${GITHUB_USER}/containers/n8n"

usage() {
  cat <<'EOF'
Usage: ./sync-releases.sh [options]

Sync upstream n8n exact semver tags to ghcr.io by invoking release.sh only for
missing root tags.

Options:
  --start-version <version>  Lowest upstream version to consider. Default: 1.107.0
  --end-version <version>    Highest upstream version to consider. Default: no upper bound
  --dry-run                  Print planned actions without invoking release.sh
  --log-dir <path>           Directory for versions.txt and summary.tsv
  --no-refresh-latest        Do not repoint ghcr :latest to the newest upstream root tag
  -h, --help                 Show this help

Notes:
  - Only exact tags like 1.123.27 or 2.14.1 are considered.
  - Suffix tags such as -amd64, -arm64, -exp.0 are ignored.
  - Existing ghcr root tags are skipped.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_cmd() {
  local cmd
  for cmd in "$@"; do
    command -v "${cmd}" >/dev/null 2>&1 || die "Required command not found: ${cmd}"
  done
}

is_exact_semver() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

version_le() {
  local lhs_major lhs_minor lhs_patch rhs_major rhs_minor rhs_patch

  IFS=. read -r lhs_major lhs_minor lhs_patch <<< "$1"
  IFS=. read -r rhs_major rhs_minor rhs_patch <<< "$2"

  if (( 10#${lhs_major} != 10#${rhs_major} )); then
    (( 10#${lhs_major} < 10#${rhs_major} ))
    return
  fi

  if (( 10#${lhs_minor} != 10#${rhs_minor} )); then
    (( 10#${lhs_minor} < 10#${rhs_minor} ))
    return
  fi

  (( 10#${lhs_patch} <= 10#${rhs_patch} ))
}

version_ge() {
  local lhs_major lhs_minor lhs_patch rhs_major rhs_minor rhs_patch

  IFS=. read -r lhs_major lhs_minor lhs_patch <<< "$1"
  IFS=. read -r rhs_major rhs_minor rhs_patch <<< "$2"

  if (( 10#${lhs_major} != 10#${rhs_major} )); then
    (( 10#${lhs_major} > 10#${rhs_major} ))
    return
  fi

  if (( 10#${lhs_minor} != 10#${rhs_minor} )); then
    (( 10#${lhs_minor} > 10#${rhs_minor} ))
    return
  fi

  (( 10#${lhs_patch} >= 10#${rhs_patch} ))
}

root_tag_exists() {
  local image_ref="${GHCR_IMAGE}:root-$1"
  local inspect_output

  if inspect_output=$(docker manifest inspect "${image_ref}" 2>&1); then
    return 0
  fi

  if [[ "${inspect_output}" == *"no such manifest"* ]] || [[ "${inspect_output}" == *"manifest unknown"* ]]; then
    return 1
  fi

  if [[ "${inspect_output}" == *"unauthorized"* ]] || [[ "${inspect_output}" == *"authentication required"* ]] || [[ "${inspect_output}" == *"requested access to the resource is denied"* ]]; then
    die "Failed to inspect ${image_ref}: authentication required; run 'docker login ghcr.io' and retry"
  fi

  printf '%s\n' "${inspect_output}" >&2
  die "Failed to inspect ${image_ref}"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --start-version)
        [[ $# -ge 2 ]] || die "--start-version requires a value"
        START_VERSION="$2"
        shift 2
        ;;
      --end-version)
        [[ $# -ge 2 ]] || die "--end-version requires a value"
        END_VERSION="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --log-dir)
        [[ $# -ge 2 ]] || die "--log-dir requires a value"
        LOG_DIR="$2"
        shift 2
        ;;
      --no-refresh-latest)
        REFRESH_LATEST=0
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done
}

fetch_upstream_versions() {
  local page response next

  page=1
  while :; do
    response=$(curl -fsSL "https://hub.docker.com/v2/repositories/${UPSTREAM_REPO}/tags?page_size=100&page=${page}")

    jq -r '.results[].name | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' <<<"${response}"

    next=$(jq -r '.next // empty' <<<"${response}")
    [[ -n "${next}" ]] || break
    page=$((page + 1))
  done \
    | sort -t. -k1,1n -k2,2n -k3,3n \
    | awk '!seen[$0]++' \
    | while read -r version; do
        version_ge "${version}" "${START_VERSION}" || continue

        if [[ -n "${END_VERSION}" ]]; then
          version_le "${version}" "${END_VERSION}" || continue
        fi

        printf '%s\n' "${version}"
      done
}

ensure_log_dir() {
  if [[ -n "${LOG_DIR}" ]]; then
    mkdir -p "${LOG_DIR}"
  else
    LOG_DIR=$(mktemp -d /tmp/n8n-sync.XXXXXX)
  fi
}

refresh_latest_tag() {
  local latest_version="$1"

  if [[ "${REFRESH_LATEST}" -ne 1 ]]; then
    echo "Skip latest retag: disabled"
    return
  fi

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "Would retag ${GHCR_IMAGE}:latest -> ${GHCR_IMAGE}:root-${latest_version}"
    printf 'latest\tPLAN\troot-%s\n' "${latest_version}" >> "${SUMMARY_FILE}"
    return
  fi

  echo "Retagging ${GHCR_IMAGE}:latest -> ${GHCR_IMAGE}:root-${latest_version}"
  docker buildx imagetools create \
    --tag "${GHCR_IMAGE}:latest" \
    "${GHCR_IMAGE}:root-${latest_version}" >/dev/null
  printf 'latest\tOK\troot-%s\n' "${latest_version}" >> "${SUMMARY_FILE}"
}

parse_args "$@"

require_cmd bash curl jq sort awk docker
is_exact_semver "${START_VERSION}" || die "Invalid --start-version: ${START_VERSION}"
if [[ -n "${END_VERSION}" ]]; then
  is_exact_semver "${END_VERSION}" || die "Invalid --end-version: ${END_VERSION}"
  version_le "${START_VERSION}" "${END_VERSION}" || die "--start-version must be <= --end-version"
fi

[[ -x "${RELEASE_SCRIPT_DEFAULT}" ]] || die "release script is not executable: ${RELEASE_SCRIPT_DEFAULT}"

ensure_log_dir

VERSIONS_FILE="${LOG_DIR}/versions.txt"
MISSING_FILE="${LOG_DIR}/missing.txt"
SUMMARY_FILE="${LOG_DIR}/summary.tsv"

fetch_upstream_versions > "${VERSIONS_FILE}"
[[ -s "${VERSIONS_FILE}" ]] || die "No upstream versions found in the requested range"

UPSTREAM_VERSIONS=()
while IFS= read -r version; do
  UPSTREAM_VERSIONS+=("${version}")
done < "${VERSIONS_FILE}"

LATEST_UPSTREAM_VERSION="${UPSTREAM_VERSIONS[${#UPSTREAM_VERSIONS[@]}-1]}"

printf 'target\tstatus\tdetails\n' > "${SUMMARY_FILE}"
> "${MISSING_FILE}"

for version in "${UPSTREAM_VERSIONS[@]}"; do
  if root_tag_exists "${version}"; then
    printf 'SKIP %s\n' "${version}"
    printf '%s\tSKIP\troot tag already exists\n' "${version}" >> "${SUMMARY_FILE}"
  else
    printf '%s\n' "${version}" >> "${MISSING_FILE}"
  fi
done

MISSING_VERSIONS=()
while IFS= read -r version; do
  MISSING_VERSIONS+=("${version}")
done < "${MISSING_FILE}"

echo "Log dir: ${LOG_DIR}"
echo "Upstream versions: ${#UPSTREAM_VERSIONS[@]}"
echo "Missing root tags: ${#MISSING_VERSIONS[@]}"
echo "Latest upstream version: ${LATEST_UPSTREAM_VERSION}"

if [[ "${#MISSING_VERSIONS[@]}" -eq 0 ]]; then
  echo "Nothing to build"
  refresh_latest_tag "${LATEST_UPSTREAM_VERSION}"
  echo "Complete"
  exit 0
fi

for version in "${MISSING_VERSIONS[@]}"; do
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "PLAN ${version}"
    printf '%s\tPLAN\tmissing root tag\n' "${version}" >> "${SUMMARY_FILE}"
    continue
  fi

  echo "START ${version} $(date '+%F %T %z')"
  if (
    cd "${SCRIPT_DIR}"
    N8N_VERSION="${version}" "${RELEASE_SCRIPT_DEFAULT}"
  ) > "${LOG_DIR}/${version}.log" 2>&1; then
    echo "DONE ${version} $(date '+%F %T %z')"
    printf '%s\tOK\t%s\n' "${version}" "${LOG_DIR}/${version}.log" >> "${SUMMARY_FILE}"
  else
    echo "FAIL ${version} $(date '+%F %T %z')"
    printf '%s\tFAIL\t%s\n' "${version}" "${LOG_DIR}/${version}.log" >> "${SUMMARY_FILE}"
    tail -n 80 "${LOG_DIR}/${version}.log" >&2 || true
    exit 1
  fi
done

if [[ "${MISSING_VERSIONS[${#MISSING_VERSIONS[@]}-1]}" != "${LATEST_UPSTREAM_VERSION}" ]]; then
  refresh_latest_tag "${LATEST_UPSTREAM_VERSION}"
fi

echo "Complete"
