#!/bin/sh

die () { echo "$*" ; echo "|${NVM_DIR}|"; exit 1; }

supports_source_options () {
  [ "_$(echo 'echo $1' | . /dev/stdin yes)" = "_yes" ]
}

if ! supports_source_options; then
  echo 'this shell does not support passing options on sourcing'
  exit 0;
fi

echo '0.10.2' > .nvmrc || die 'creation of .nvmrc failed'

export NVM_DIR="${PWD}/../.."
rm ../../alias/default

\. ../../nvm.sh --install
EXIT_CODE="$?"

echo 'sourcing complete.'

[ "_$(nvm_rc_version | \grep -o -e 'with version .*$')" = "_with version <0.10.2>" ] || die "nvm_rc_version $(nvm_rc_version)"

nvm_version 0.10.2 >/dev/null 2>&1 || die "v0.10.2 not installed: \n$(nvm_ls)"

[ "_${EXIT_CODE}" = '_0' ] || die "sourcing returned nonzero exit code: ${EXIT_CODE}"

NVM_LS_CURRENT="$(nvm ls current | \grep -o v0.10.2)"
[ "_$NVM_LS_CURRENT" = '_v0.10.2' ] || die "'nvm ls current' did not return '-> v0.10.2', got >${NVM_LS_CURRENT}<\n$(nvm_ls)"

rm .nvmrc
