#!/bin/sh

set -e

cleanup() {
  nvm cache clear
  nvm deactivate
  rm -rf "${NVM_DIR}"/v*
  nvm unalias default
}

die() {
  echo "$@"
  cleanup || true
  exit 1
}

\. ../../nvm.sh

if [ -z "${BASH-}" ]; then
  echo "This test only applies to Bash; skipping"
  exit
fi

cleanup || true
trap 'echo "==> EXIT signal received (status: $?)"; cleanup' EXIT

# shellcheck disable=SC3047
trap 'echo "==> ERR signal received"; exit 1' ERR
# shellcheck disable=SC3041
set -E

# shellcheck disable=SC3045,SC3047
ERR_TRAP_EXPECTED="$(trap -p ERR)"

# Adding ` || die 'install failed'` implicitly disables error handling and
# prevents ERR trap execution, so for the purposes of this test, `nvm install`
# can't be part of another command or statement
nvm install node

case "$-" in
*E*)
  # shellcheck disable=SC3045,SC3047
  [ "$(trap -p ERR)" = "$ERR_TRAP_EXPECTED" ] ||
    die "ERR trap not restored after \"nvm install $VERSION\""
  ;;
*)
  die "errtrace not restored after \"nvm install $VERSION\""
  ;;
esac
