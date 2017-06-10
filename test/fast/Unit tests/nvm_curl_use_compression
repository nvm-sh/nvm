#!/bin/sh

cleanup () {
  unset -f die
}

die () { echo -e "$@" ; cleanup ;  exit 1; }

NVM_ENV=testing \. ../../../nvm.sh

curl() {
  if [ "$1" = "-V" ]; then
    echo "${VERSION_MESSAGE}"
  fi
}

CURL_VERSION_ON_ARCHLINUX_WITH_LIBZ="curl 7.54.0 (x86_64-pc-linux-gnu) libcurl/7.54.0 OpenSSL/1.1.0f zlib/1.2.11 libpsl/0.17.0 (+libicu/59.1) libssh2/1.8.0 nghttp2/1.22.0
Protocols: dict file ftp ftps gopher http https imap imaps pop3 pop3s rtsp scp sftp smb smbs smtp smtps telnet tftp
Features: AsynchDNS IPv6 Largefile GSS-API Kerberos SPNEGO NTLM NTLM_WB SSL libz TLS-SRP HTTP2 UnixSockets HTTPS-proxy PSL"

CURL_VERSION_ON_ARCHLINUX_WITHOUT_LIBZ="curl 7.54.0 (x86_64-pc-linux-gnu) libcurl/7.54.0 OpenSSL/1.1.0f zlib/1.2.11 libpsl/0.17.0 (+libicu/59.1) libssh2/1.8.0 nghttp2/1.22.0
Protocols: dict file ftp ftps gopher http https imap imaps pop3 pop3s rtsp scp sftp smb smbs smtp smtps telnet tftp
Features: AsynchDNS IPv6 Largefile GSS-API Kerberos SPNEGO NTLM NTLM_WB SSL TLS-SRP HTTP2 UnixSockets HTTPS-proxy PSL"

CURL_VERSION_ON_CENTOS6_WITH_LIBZ="curl 7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.19.1 Basic ECC zlib/1.2.3 libidn/1.18 libssh2/1.4.2
Protocols: tftp ftp telnet dict ldap ldaps http file https ftps scp sftp
Features: GSS-Negotiate IDN IPv6 Largefile NTLM SSL libz"

VERSION_MESSAGE="${CURL_VERSION_ON_ARCHLINUX_WITH_LIBZ}"
nvm_curl_use_compression || die "nvm_curl_use_compression should return 0"

VERSION_MESSAGE="${CURL_VERSION_ON_ARCHLINUX_WITHOUT_LIBZ}"
! nvm_curl_use_compression || die "nvm_curl_use_compression should return 1 without libz support"

VERSION_MESSAGE="${CURL_VERSION_ON_CENTOS6_WITH_LIBZ}"
! nvm_curl_use_compression || die "nvm_curl_use_compression should return 1 when curl < 7.21.0"

cleanup
