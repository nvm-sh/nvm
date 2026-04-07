#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm use 0.10

nvm exec stable -- node --help | grep 'Usage: node [options]' || die "Help menu should have been displayed for node and not nvm"
