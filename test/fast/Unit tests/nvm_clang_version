#!/bin/sh

cleanup () {
  unset -f die
}

die () { echo -e "$@" ; cleanup ;  exit 1; }

if type "clang" > /dev/null 2>&1 ; then
  clang_exec="$(type "clang")"
  sudo rm -rf "${clang_exec}"
fi
if type "clang++" > /dev/null 2>&1 ; then
  clangxx_exec="$(type "clang++")"
  sudo rm -rf "${clangxx_exec}"
fi

NVM_ENV=testing \. ../../../nvm.sh

clang() {
  if [ "$1" = "--version" ]; then
    echo "${VERSION_MESSAGE}"
  fi
}

assert_version_is() {
  if [ "${1}" != "${2}" ]; then
    die "Expected ${2}, got ${1}, origin version message:\n${VERSION_MESSAGE}"
    return 1
  fi
}

CLANG_VERSION_ON_DEBIAN_JESSIE="Debian clang version 3.5.0-10 (tags/RELEASE_350/final) (based on LLVM 3.5.0)
Target: x86_64-pc-linux-gnu
Thread model: posix"

CLANG_VERSION_ON_UBUNTU_TRUSTY="Ubuntu clang version 3.4-1ubuntu3 (tags/RELEASE_34/final) (based on LLVM 3.4)
Target: x86_64-pc-linux-gnu
Thread model: posix"

CLANG_VERSION_ON_ARCHLINUX="clang version 3.9.0 (tags/RELEASE_390/final)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /usr/sbin"

CLANG_VERSION_ON_FREEBSD="FreeBSD clang version 3.4.1 (tags/RELEASE_34/dot1-final 208032) 20140512
Target: x86_64-unknown-freebsd10.3
Thread model: posix"

VERSION_MESSAGE="${CLANG_VERSION_ON_DEBIAN_JESSIE}"
assert_version_is "$(nvm_clang_version)" "3.5.0"

VERSION_MESSAGE="${CLANG_VERSION_ON_UBUNTU_TRUSTY}"
assert_version_is "$(nvm_clang_version)" "3.4"

VERSION_MESSAGE="${CLANG_VERSION_ON_ARCHLINUX}"
assert_version_is "$(nvm_clang_version)" "3.9.0"

VERSION_MESSAGE="${CLANG_VERSION_ON_FREEBSD}"
assert_version_is "$(nvm_clang_version)" "3.4.1"

cleanup
