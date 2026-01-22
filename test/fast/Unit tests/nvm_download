#!/bin/sh

cleanup () {
  unset -f die cleanup
  docker stop httpbin && docker rm httpbin
}
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

set -ex

# nvm_download install.sh
nvm_download "https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh" >/dev/null || die "nvm_download unable to download install.sh"

# nvm_download should fail to download wrong_install.sh
! nvm_download "https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/wrong_install.sh" >/dev/null || die "nvm_download should fail to download no existing file"

# nvm_download should pass when calling with auth header
docker pull kennethreitz/httpbin && SHELL=bash docker run -d --name httpbin -p 80:80 kennethreitz/httpbin
sleep 1 # wait for httpbin to start
NVM_AUTH_HEADER="Bearer test-token" nvm_download "http://127.0.0.1/bearer" > /dev/null || die 'nvm_download with auth header should send correctly'

# nvm_download should fail when calling without auth header
nvm_download "http://127.0.0.1/bearer" > /dev/null && die 'nvm_download with no auth header should not send the header and should fail'

# ensure quoted extra args remain quoted
nvm_download "https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh" -o "; die quoted-command-not-quoted" || die 'command failed'

cleanup
