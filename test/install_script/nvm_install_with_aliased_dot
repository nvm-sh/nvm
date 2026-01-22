#!/bin/sh

setup() {
  # Needed to avoid to checkout the repo to the latest nvm version, losing the commits of the current PR
  unset NVM_DIR
  shopt -s expand_aliases
  alias .=':'
  NVM_ENV=testing \. ../../install.sh > /dev/null
}

cleanup () {
  unset -f setup cleanup die
  unalias .
  shopt -u expand_aliases
}

die () { echo "$@"; cleanup; exit 1; }

setup

nvm_do_install > /dev/null 2>&1
command -v nvm || die 'nvm could not be loaded'

cleanup
