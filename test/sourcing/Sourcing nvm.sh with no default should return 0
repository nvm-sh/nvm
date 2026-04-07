#!/bin/sh

die () { echo "$@" ; exit 1; }

touch ../../alias/default
rm ../../alias/default || die 'removal of default alias failed'
nvm_alias default && die '"nvm_alias default" did not fail'

set -e # necessary to fail internally with a nonzero code

\. ../../nvm.sh || die 'sourcing returned nonzero exit code'
