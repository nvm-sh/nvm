#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

get_packages() {
  npm list -g --depth=0 | \sed -e '1 d' -e 's/^.* \(.*\)@.*/\1/' -e '/^npm$/ d' | xargs
}

nvm use 4.7.2
ORIGINAL_PACKAGES=$(get_packages)

nvm reinstall-packages 4.7.1
FINAL_PACKAGES=$(get_packages)

[ -z "${ORIGINAL_PACKAGES}" ] || die "original packages were not empty: ${ORIGINAL_PACKAGES}"
[ -z "${FINAL_PACKAGES}" ] || die "final packages were not empty: ${FINAL_PACKAGES}"
