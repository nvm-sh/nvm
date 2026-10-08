#!/bin/sh

# Install apt packages, riding out Ubuntu/Debian mirror outages: apt itself
# retries each request, and the whole update+install is retried with backoff
# for about 10 minutes, since outages have lasted longer than apt's own retries.
#
# usage: sh .github/scripts/apt-install.sh <package>...
# Runs apt-get through sudo when not root.

set -u

if [ "$#" -eq 0 ]; then
  echo 'usage: apt-install.sh <package>...' >&2
  exit 2
fi

SUDO=''
if [ "$(id -u)" != '0' ]; then
  SUDO='sudo'
fi

apt_get() {
  # never prompt: an upgrade (e.g. libssl asking to restart services) would wait forever
  $SUDO env DEBIAN_FRONTEND=noninteractive apt-get \
    -o Acquire::Retries=5 \
    -o Acquire::http::Timeout=30 \
    -o Acquire::https::Timeout=30 \
    -o Dpkg::Options::=--force-confdef \
    -o Dpkg::Options::=--force-confold \
    "$@" < /dev/null
}

ATTEMPT=1
MAX_ATTEMPTS=8
DELAY=15
while :; do
  apt_get update || echo "apt-get update failed (attempt ${ATTEMPT}/${MAX_ATTEMPTS})" >&2
  if apt_get install -y "$@"; then
    exit 0
  fi
  if [ "${ATTEMPT}" -ge "${MAX_ATTEMPTS}" ]; then
    echo "apt-get install failed after ${MAX_ATTEMPTS} attempts: $*" >&2
    exit 1
  fi
  echo "apt-get install failed (attempt ${ATTEMPT}/${MAX_ATTEMPTS}); retrying in ${DELAY}s" >&2
  sleep "${DELAY}"
  ATTEMPT=$((ATTEMPT + 1))
  DELAY=$((DELAY * 2))
  if [ "${DELAY}" -gt 120 ]; then
    DELAY=120
  fi
done
