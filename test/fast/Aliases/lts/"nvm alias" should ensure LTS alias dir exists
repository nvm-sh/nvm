#!/bin/sh

set -ex

\. ../../../../nvm.sh
\. ../../../common.sh

LTS_ALIAS_PATH="$(nvm_alias_path)/lts"

rm -rf "${LTS_ALIAS_PATH}"

die () { echo "$@" ; exit 1; }

[ ! -d "${LTS_ALIAS_PATH}" ] || die "'${LTS_ALIAS_PATH}' exists and should not"

nvm alias >/dev/null 2>&1

[ -d "${LTS_ALIAS_PATH}" ] || die "'${LTS_ALIAS_PATH}' does not exist and should"
