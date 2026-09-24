#!/usr/bin/env bash

set -euo pipefail

# Mirror upstream ollama/ollama stable semver tags to ghcr.io.
#
# Upstream tags are copied as-is with `docker buildx imagetools create` so that
# multi-architecture manifest lists are preserved without a local pull/build.
# Tags already present on GHCR are skipped, and :latest is repointed to the
# newest mirrored stable version.
#
# Usage: ./pull-push.sh [options]
#   --start-version <ver>   Lowest upstream version to mirror (inclusive)
#   --end-version <ver>     Highest upstream version to mirror (inclusive)
#   --dry-run               Print planned actions, mirror nothing
#   --list-only             Just print available upstream stable tags and exit
#   --no-refresh-latest     Do not repoint :latest to the newest stable
#   --log-dir <path>        Directory for versions.txt / missing.txt / summary.tsv
#   -h, --help              Show this help
#
# Requires: bash curl jq sort awk docker (with buildx)
# Run `docker login ghcr.io` before pushing.

UPSTREAM_REPO="ollama/ollama"
GITHUB_USER="${GITHUB_USER:-doridoridoriand}"
GHCR_IMAGE="ghcr.io/${GITHUB_USER}/containers/ollama"
START_VERSION=""
END_VERSION=""
DRY_RUN=0
REFRESH_LATEST=1
LIST_ONLY=0
LOG_DIR=""

usage() {
  cat <<'EOF'
Usage: ./pull-push.sh [options]

Mirror upstream ollama/ollama stable semver tags (e.g. 0.34.2) to ghcr.io.
Tags already on GHCR are skipped; :latest is repointed to the newest stable.

Options:
  --start-version <version>  Lowest upstream version to consider (inclusive)
  --end-version <version>    Highest upstream version to consider (inclusive)
  --dry-run                  Print planned actions without mirroring
  --list-only                Print available upstream stable tags and exit
  --no-refresh-latest        Do not repoint ghcr :latest to the newest stable
  --log-dir <path>           Directory for versions.txt, missing.txt, summary.tsv
  -h, --help                 Show this help

Notes:
  - Only exact semver tags like 0.34.2 are considered.
  - Suffix tags such as -rc0, -rocm, and v-prefixed tags are ignored.
  - Existing ghcr tags are skipped.
  - Requires docker with buildx; run 'docker login ghcr.io' before pushing.
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

tag_exists_at_ghcr() {
  local image_ref="${GHCR_IMAGE}:$1"
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

fetch_upstream_versions() {
  local token hdr_tmp url response next

  token=$(curl -fsSL "https://auth.docker.io/token?scope=repository%3A${UPSTREAM_REPO}%3Apull&service=registry.docker.io" | jq -r '.token')
  hdr_tmp=$(mktemp)
  url="/v2/${UPSTREAM_REPO}/tags/list?n=100"

  while [[ -n "${url}" ]]; do
    response=$(curl -fsSL -D "${hdr_tmp}" -H "Authorization: Bearer ${token}" "https://registry-1.docker.io${url}")
    jq -r '.tags[]? | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' <<<"${response}"

    next=$(grep -i '^link:' "${hdr_tmp}" | sed -E 's/.*<([^>]+)>.*/\1/' || true)
    if [[ -z "${next}" ]]; then
      url=""
    else
      url="${next}"
    fi
  done

  rm -f "${hdr_tmp}"
}

mirror_tag() {
  local version="$1"
  local src="docker.io/${UPSTREAM_REPO}:${version}"
  local dst="${GHCR_IMAGE}:${version}"

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "PLAN  ${src} -> ${dst}"
    printf '%s\tPLAN\t%s\n' "${version}" "${src}" >> "${SUMMARY_FILE}"
    return
  fi

  echo "COPY  ${src} -> ${dst}"
  if docker buildx imagetools create --tag "${dst}" "${src}" >/dev/null; then
    printf '%s\tOK\t%s\n' "${version}" "${src}" >> "${SUMMARY_FILE}"
  else
    printf '%s\tFAIL\t%s\n' "${version}" "${src}" >> "${SUMMARY_FILE}"
    die "Failed to mirror ${src} -> ${dst}"
  fi
}

refresh_latest_tag() {
  local latest_version="$1"

  if [[ "${REFRESH_LATEST}" -ne 1 ]]; then
    echo "Skip latest retag: disabled"
    return
  fi

  local src="${GHCR_IMAGE}:${latest_version}"
  local dst="${GHCR_IMAGE}:latest"

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "PLAN  ${src} -> ${dst}"
    printf 'latest\tPLAN\t%s\n' "${latest_version}" >> "${SUMMARY_FILE}"
    return
  fi

  echo "RETAG ${src} -> ${dst}"
  if docker buildx imagetools create --tag "${dst}" "${src}" >/dev/null; then
    printf 'latest\tOK\t%s\n' "${latest_version}" >> "${SUMMARY_FILE}"
  else
    printf 'latest\tFAIL\t%s\n' "${latest_version}" >> "${SUMMARY_FILE}"
    die "Failed to retag ${src} -> ${dst}"
  fi
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
      --list-only)
        LIST_ONLY=1
        shift
        ;;
      --no-refresh-latest)
        REFRESH_LATEST=0
        shift
        ;;
      --log-dir)
        [[ $# -ge 2 ]] || die "--log-dir requires a value"
        LOG_DIR="$2"
        shift 2
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

parse_args "$@"

require_cmd bash curl jq sort awk docker

if [[ -n "${START_VERSION}" ]]; then
  is_exact_semver "${START_VERSION}" || die "Invalid --start-version: ${START_VERSION}"
fi
if [[ -n "${END_VERSION}" ]]; then
  is_exact_semver "${END_VERSION}" || die "Invalid --end-version: ${END_VERSION}"
fi
if [[ -n "${START_VERSION}" && -n "${END_VERSION}" ]]; then
  version_le "${START_VERSION}" "${END_VERSION}" || die "--start-version must be <= --end-version"
fi

if [[ "${LIST_ONLY}" -eq 1 ]]; then
  fetch_upstream_versions \
    | sort -t. -k1,1n -k2,2n -k3,3n \
    | awk '!seen[$0]++' \
    | while read -r version; do
        if [[ -n "${START_VERSION}" ]]; then
          version_ge "${version}" "${START_VERSION}" || continue
        fi
        if [[ -n "${END_VERSION}" ]]; then
          version_le "${version}" "${END_VERSION}" || continue
        fi
        printf '%s\n' "${version}"
      done
  exit 0
fi

if [[ -n "${LOG_DIR}" ]]; then
  mkdir -p "${LOG_DIR}"
else
  LOG_DIR=$(mktemp -d /tmp/ollama-mirror.XXXXXX)
fi

VERSIONS_FILE="${LOG_DIR}/versions.txt"
MISSING_FILE="${LOG_DIR}/missing.txt"
SUMMARY_FILE="${LOG_DIR}/summary.tsv"

fetch_upstream_versions \
  | sort -t. -k1,1n -k2,2n -k3,3n \
  | awk '!seen[$0]++' \
  | while read -r version; do
      if [[ -n "${START_VERSION}" ]]; then
        version_ge "${version}" "${START_VERSION}" || continue
      fi
      if [[ -n "${END_VERSION}" ]]; then
        version_le "${version}" "${END_VERSION}" || continue
      fi
      printf '%s\n' "${version}"
    done > "${VERSIONS_FILE}"

[[ -s "${VERSIONS_FILE}" ]] || die "No upstream versions found in the requested range"

UPSTREAM_VERSIONS=()
while IFS= read -r version; do
  UPSTREAM_VERSIONS+=("${version}")
done < "${VERSIONS_FILE}"

LATEST_UPSTREAM_VERSION="${UPSTREAM_VERSIONS[${#UPSTREAM_VERSIONS[@]}-1]}"

printf 'target\tstatus\tdetails\n' > "${SUMMARY_FILE}"
> "${MISSING_FILE}"

for version in "${UPSTREAM_VERSIONS[@]}"; do
  if tag_exists_at_ghcr "${version}"; then
    printf 'SKIP %s\n' "${version}"
    printf '%s\tSKIP\talready on ghcr\n' "${version}" >> "${SUMMARY_FILE}"
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
echo "Missing on ghcr: ${#MISSING_VERSIONS[@]}"
echo "Latest upstream version: ${LATEST_UPSTREAM_VERSION}"
echo "GHCR image: ${GHCR_IMAGE}"

if [[ "${#MISSING_VERSIONS[@]}" -eq 0 ]]; then
  echo "Nothing to mirror"
  refresh_latest_tag "${LATEST_UPSTREAM_VERSION}"
  echo "Complete"
  exit 0
fi

for version in "${MISSING_VERSIONS[@]}"; do
  mirror_tag "${version}"
done

refresh_latest_tag "${LATEST_UPSTREAM_VERSION}"

echo "Complete"
