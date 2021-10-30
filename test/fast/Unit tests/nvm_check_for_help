#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

TERM=dumb nvm clear-cache --help | grep 'Usage:' || die 'did not print help menu'
TERM=dumb nvm cache help version | grep 'Usage:' || die 'did not print help menu'
TERM=dumb nvm cache -h version| grep 'Usage:' || die 'did not print help menu'
