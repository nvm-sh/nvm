#!/bin/sh

cleanup() {
    unset nvm_get_os
    unset nvm_get_arch
}

die () { cleanup; echo "$@" ; exit 1; }

\. ../../../nvm.sh

[ "$(nvm_get_download_slug 2>/dev/null ; echo $?)" = '1' ] || die 'invalid flavor did not fail with exit code 1'
[ "$(nvm_get_download_slug 2>&1)" = 'supported flavors: node, iojs' ] || die 'invalid flavor did not fail with expected message'

[ "$(nvm_get_download_slug node 2>/dev/null ; echo $?)" = '2' ] || die 'invalid kind did not fail with exit code 2'
[ "$(nvm_get_download_slug node 2>&1)" = 'supported kinds: binary, source' ] || die 'invalid kind did not fail with expected message'
[ "$(nvm_get_download_slug iojs 2>/dev/null ; echo $?)" = '2' ] || die 'invalid kind did not fail with exit code 2'
[ "$(nvm_get_download_slug iojs 2>&1)" = 'supported kinds: binary, source' ] || die 'invalid kind did not fail with expected message'

nvm_get_os() {
    echo omgOS
}
nvm_get_arch() {
    echo nemesis
}

ACTUAL="$(nvm_get_download_slug node binary 1.2.3)"
EXPECTED='node-1.2.3-omgOS-nemesis'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs binary 1.2.3)"
EXPECTED='iojs-1.2.3-omgOS-nemesis'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

ACTUAL="$(nvm_get_download_slug node source 1.2.3)"
EXPECTED="node-1.2.3"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs source 1.2.3)"
EXPECTED="iojs-1.2.3"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

nvm_get_arch() {
    echo armv6l
}
ACTUAL="$(nvm_get_download_slug node binary 1.2.3)"
EXPECTED='node-1.2.3-omgOS-arm-pi'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs binary 1.2.3)"
EXPECTED='iojs-1.2.3-omgOS-arm-pi'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

ACTUAL="$(nvm_get_download_slug node source 1.2.3)"
EXPECTED="node-1.2.3"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs source 1.2.3)"
EXPECTED="iojs-1.2.3"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

nvm_get_arch() {
    echo armv7l
}
ACTUAL="$(nvm_get_download_slug node binary 1.2.3)"
EXPECTED='node-1.2.3-omgOS-arm-pi'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs binary 1.2.3)"
EXPECTED='iojs-1.2.3-omgOS-arm-pi'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

ACTUAL="$(nvm_get_download_slug node source 1.2.3)"
EXPECTED="node-1.2.3"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs source 1.2.3)"
EXPECTED="iojs-1.2.3"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

nvm_get_os() {
    echo darwin
}
nvm_get_arch() {
    echo nemesis
}
ACTUAL="$(nvm_get_download_slug node binary 15.99.99)"
EXPECTED='node-15.99.99-darwin-nemesis'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs binary 15.99.99)"
EXPECTED='iojs-15.99.99-darwin-nemesis'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

ACTUAL="$(nvm_get_download_slug node source 15.99.99)"
EXPECTED="node-15.99.99"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs source 15.99.99)"
EXPECTED="iojs-15.99.99"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

nvm_get_arch() {
    echo arm64
}
ACTUAL="$(nvm_get_download_slug node binary 15.99.99)"
EXPECTED='node-15.99.99-darwin-x64'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs binary 15.99.99)"
EXPECTED='iojs-15.99.99-darwin-x64'
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

ACTUAL="$(nvm_get_download_slug node source 15.99.99)"
EXPECTED="node-15.99.99"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
ACTUAL="$(nvm_get_download_slug iojs source 15.99.99)"
EXPECTED="iojs-15.99.99"
[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"

