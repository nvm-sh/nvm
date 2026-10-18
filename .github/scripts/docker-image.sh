#!/bin/sh

# Cache a container image as a tarball, keyed by digests looked up live from the registry: a cached
# image is only used if it is exactly what the registry serves now, so a poisoned cache entry is never used.
#
# usage:
#   sh .github/scripts/docker-image.sh resolve <image>
#     prints `key=<config digest>` and `digests=<index, manifest, and config digests>`, for $GITHUB_OUTPUT
#   DIGESTS='<digests>' sh .github/scripts/docker-image.sh ensure <image> <tarball>
#     loads <tarball> if it holds one of $DIGESTS; otherwise pulls <image>, checks it, and saves it to <tarball>

set -eu

ACCEPT='application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.manifest.v1+json,application/vnd.docker.distribution.manifest.v2+json'

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1"
  else
    shasum -a 256 "$1"
  fi | cut -d ' ' -f 1
}

# fetches a manifest into a file; digests are computed from its exact bytes
registry_get() {
  curl -fsSL --retry 5 --retry-all-errors -H "Accept: ${ACCEPT}" -o "$2" "$1"
}

resolve() {
  IMAGE="$1"
  HOST="${IMAGE%%/*}"
  REST="${IMAGE#*/}"
  REPO="${REST%:*}"
  TAG="${REST##*:}"
  OS="$(docker version --format '{{.Server.Os}}')"
  ARCH="$(docker version --format '{{.Server.Arch}}')"

  WORK="$(mktemp -d)"
  trap 'rm -rf "${WORK}"' EXIT

  registry_get "https://${HOST}/v2/${REPO}/manifests/${TAG}" "${WORK}/index.json"
  INDEX_DIGEST="sha256:$(sha256_of "${WORK}/index.json")"

  if jq -e '.manifests' "${WORK}/index.json" >/dev/null; then
    MANIFEST_DIGEST="$(jq -r --arg os "${OS}" --arg arch "${ARCH}" '[.manifests[] | select(.platform.os == $os and .platform.architecture == $arch)][0].digest // empty' "${WORK}/index.json")"
    if [ -z "${MANIFEST_DIGEST}" ]; then
      echo "${IMAGE} has no ${OS}/${ARCH} image" >&2
      exit 1
    fi
    registry_get "https://${HOST}/v2/${REPO}/manifests/${MANIFEST_DIGEST}" "${WORK}/manifest.json"
    if [ "sha256:$(sha256_of "${WORK}/manifest.json")" != "${MANIFEST_DIGEST}" ]; then
      echo "the ${OS}/${ARCH} manifest of ${IMAGE} does not match its digest" >&2
      exit 1
    fi
  else
    MANIFEST_DIGEST="${INDEX_DIGEST}"
    cp "${WORK}/index.json" "${WORK}/manifest.json"
  fi

  CONFIG_DIGEST="$(jq -r '.config.digest' "${WORK}/manifest.json")"
  echo "key=${CONFIG_DIGEST}"
  echo "digests=${INDEX_DIGEST} ${MANIFEST_DIGEST} ${CONFIG_DIGEST}"
}

# an image's ID is its config digest (or, with the containerd image store, its manifest or index digest)
image_matches() {
  ID="$(docker image inspect --format '{{.Id}}' "$1" 2>/dev/null)" || return 1
  case " ${DIGESTS} " in
    *" ${ID} "*) return 0 ;;
  esac
  return 1
}

ensure() {
  IMAGE="$1"
  TARBALL="$2"

  if [ -f "${TARBALL}" ]; then
    if docker load -i "${TARBALL}" && image_matches "${IMAGE}"; then
      echo "loaded ${IMAGE} from the cache"
      return 0
    fi
    echo "::warning::the cached ${IMAGE} does not match the registry's digests; pulling it instead"
    docker image rm -f "${IMAGE}" >/dev/null 2>&1 || true
    rm -f "${TARBALL}"
  fi

  ATTEMPT=1
  until docker pull "${IMAGE}"; do
    if [ "${ATTEMPT}" -ge 5 ]; then
      echo "docker pull ${IMAGE} failed after ${ATTEMPT} attempts" >&2
      return 1
    fi
    echo "docker pull failed, attempt ${ATTEMPT}/5"
    sleep $((ATTEMPT * 5))
    ATTEMPT=$((ATTEMPT + 1))
  done

  # the tag can move between `resolve` and the pull; then this run uses the image, but does not cache it
  if image_matches "${IMAGE}"; then
    docker save -o "${TARBALL}" "${IMAGE}"
  else
    echo "::warning::the pulled ${IMAGE} no longer matches the digests looked up earlier; not caching it"
  fi
}

case "${1-}" in
  resolve) resolve "${2-}" ;;
  ensure) ensure "${2-}" "${3-}" ;;
  *)
    echo 'usage: docker-image.sh resolve <image> | ensure <image> <tarball>' >&2
    exit 2
  ;;
esac
