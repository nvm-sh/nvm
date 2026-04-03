#!/bin/sh

cleanup () {
  unset -f die
  unset -f curl
}

die () { echo -e "$@" ; cleanup ;  exit 1; }

NVM_ENV=testing \. ../../../nvm.sh

curl() {
  if [ "$1" = "-V" ]; then
    echo "${VERSION_MESSAGE}"
  fi
}

assert_version_is() {
  if [ "${1}" != "${2}" ]; then
    die "Expected ${2}, got ${1}, origin version message:\n${VERSION_MESSAGE}"
    return 1
  fi
}

CURL_VERSION_MESSAGE="curl 7.54.0 (x86_64-pc-linux-gnu) libcurl/7.54.0 OpenSSL/1.1.0f zlib/1.2.11 libpsl/0.17.0 (+libicu/59.1) libssh2/1.8.0 nghttp2/1.22.0
Protocols: dict file ftp ftps gopher http https imap imaps pop3 pop3s rtsp scp sftp smb smbs smtp smtps telnet tftp
Features: AsynchDNS IPv6 Largefile GSS-API Kerberos SPNEGO NTLM NTLM_WB SSL libz TLS-SRP HTTP2 UnixSockets HTTPS-proxy PSL"

VERSION_MESSAGE="${CURL_VERSION_MESSAGE}"
assert_version_is "$(nvm_curl_version)" "7.54.0"

cleanup
