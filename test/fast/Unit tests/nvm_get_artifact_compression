#!/bin/sh

cleanup () {
  unset -f die cleanup
}
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

# nvm_get_artifact_compression by default
[ "$(nvm_get_artifact_compression)" = 'tar.gz' ] || die 'nvm_get_artifact_compression should return "tar.gz" by default'

# nvm_get_artifact_compression with xz
[ "$(nvm_get_artifact_compression "14.0.0")" = 'tar.xz' ] || die 'nvm_get_artifact_compression should return "tar.xz" for this version'

# nvm_get_artifact_compression with zip on Windows
nvm_get_os() {
  nvm_echo 'win'
}
[ "$(nvm_get_artifact_compression)" = 'zip' ] || die 'nvm_get_artifact_compression should return "zip" for Windows'

cleanup
