#!/bin/sh

cleanup() {
  unset -f curl
}

die() { cleanup; echo "$@" ; exit 1; }

\. ../../../nvm.sh

curl() {
    # curl with libz feature
    if [ $# -ne 1 ] || [ "$1" != "-V" ]; then
        die "This fake curl only takes one parameter -V"
    fi
    echo "
curl 7.47.0 (x86_64-pc-linux-gnu) libcurl/7.47.0 GnuTLS/3.4.10 zlib/1.2.8 libidn/1.32 librtmp/2.3
Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtmp rtsp smb smbs smtp smtps telnet tftp
Features: AsynchDNS IDN IPv6 Largefile GSS-API Kerberos SPNEGO NTLM NTLM_WB SSL libz TLS-SRP UnixSockets"
}

nvm_curl_libz_support || die "nvm_curl_libz_support should return 0"

unset -f curl

curl() {
    # curl without libz feature
    if [ "$#" -ne 1 ] || [ "$1" != "-V" ]; then
        die "This fake curl only takes one parameter -V"
    fi
    echo "
curl 7.47.0 (x86_64-pc-linux-gnu) libcurl/7.47.0 GnuTLS/3.4.10 zlib/1.2.8 libidn/1.32 librtmp/2.32
Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtmp rtsp smb smbs smtp smtps telnet tftp
Features: AsynchDNS IDN IPv6 Largefile GSS-API Kerberos SPNEGO NTLM NTLM_WB SSL TLS-SRP UnixSockets"
}

! nvm_curl_libz_support || die "nvm_curl_libz_support should return 1"

unset -f curl
