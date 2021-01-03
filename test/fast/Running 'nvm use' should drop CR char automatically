#!/bin/sh

set -ex

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset VERSION1 VERSION2 VERSION3
  rm .nvmrc
}

\. ../../nvm.sh

# normal .nvmrc
printf '0.999.0\n'   > .nvmrc
nvm_rc_version
VERSION1="${NVM_RC_VERSION}"

# .nvmrc with CR char
printf '0.999.0\r\n' > .nvmrc
nvm_rc_version
VERSION2="${NVM_RC_VERSION}"

[ "${VERSION1}" = "${VERSION2}" ]

# .nvmrc without any newline char
printf '0.999.0' > .nvmrc
nvm_rc_version
VERSION3="${NVM_RC_VERSION}"

[ "${VERSION1}" = "${VERSION3}" ]

cleanup
