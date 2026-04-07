#!/bin/sh

cleanup () {
  unset -f die cleanup
  unset install_dir
}
die () { echo "$@" ; cleanup ; exit 1; }

NVM_ENV=testing \. ../../install.sh
HOME="__home__"


# NVM_DIR is set
NVM_DIR="some_dir"
install_dir=$(nvm_install_dir)
[ "_$install_dir" = "_$NVM_DIR" ] || die "nvm_install_dir should use \$NVM_DIR if it exists. Current output: $install_dir"

unset NVM_DIR
# NVM_DIR is not set
install_dir=$(nvm_install_dir)
fallback_dir=""
[ ! -z "$XDG_CONFIG_HOME" ] && fallback_dir="$XDG_CONFIG_HOME/nvm" || fallback_dir="$HOME/.nvm"
[ "_$install_dir" = "_$fallback_dir" ] || die "nvm_install_dir should default to \$XDG_CONFIG_DIR/.nvm. Current output: $install_dir"

cleanup
