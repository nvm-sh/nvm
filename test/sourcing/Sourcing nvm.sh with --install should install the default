#!/bin/sh
\. ../common.sh

die () { echo "$@" ; exit 1; }

supports_source_options () {
  [ "_$(echo 'echo $1' | . /dev/stdin yes)" = "_yes" ]
}

if ! supports_source_options; then
  echo 'this shell does not support passing options on sourcing'
  exit 0;
fi

rm .nvmrc
export NVM_DIR="${PWD}/../.."
echo '0.10.2' > ../../alias/default || die 'creation of default alias failed'

echo 'sourcing nvm with --install...'

\. ../../nvm.sh --install
EXIT_CODE="$?"

echo 'sourcing complete.'

[ "$(nvm_alias default)" = '0.10.2' ] || die "nvm_alias default did not return '0.10.2', got >$(nvm_alias default)<"

nvm_version 0.10.2 >/dev/null 2>&1 || die "v0.10.2 not installed: \n$(nvm_ls)"

[ "_$EXIT_CODE" = '_0' ] || die "sourcing returned nonzero exit code: ${EXIT_CODE}"

NVM_LS_CURRENT="$(nvm ls current | strip_colors | command grep -o v0.10.2)"
[ "_$NVM_LS_CURRENT" = '_v0.10.2' ] || die "'nvm ls current' did not return '-> v0.10.2', >${NVM_LS_CURRENT}<\n$(nvm_ls)"

NVM_ALIAS_DEFAULT="$(nvm alias default | strip_colors)"
[ "_$NVM_ALIAS_DEFAULT" = "_default -> 0.10.2 (-> v0.10.2)" ] \
  || die "'nvm alias default did not return 'default -> 0.10.2 (-> v0.10.2)', got >${NVM_ALIAS_DEFAULT}<\n$(nvm_ls)"
