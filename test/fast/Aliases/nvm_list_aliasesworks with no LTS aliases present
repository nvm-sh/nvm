#!/bin/sh

\. ../../../nvm.sh

die () {
  mv "$(nvm_alias_path)/_lts.bak" "$(nvm_alias_path)/lts"
  echo "$@"
  exit 1
}

set -e

nvm_alias_path() {
  nvm_echo "../../../alias"
}

mv "$(nvm_alias_path)/lts" "$(nvm_alias_path)/_lts.bak"

STDERR_OUTPUT="$(nvm_list_aliases 2>&1 >/dev/null)"

[ -z "${STDERR_OUTPUT}" ] || die "expected no stderr output, got >${STDERR_OUTPUT}<"
