#!/bin/sh

# Save the PATH as it was when the test started to restore it when it finishes
ORIG_PATH="${PATH}"

cleanup() {
  # Restore the PATH as it was when the test started
  export PATH="${ORIG_PATH}"
  rm -rf "${TMP_DIR}"
}

die() {
  cleanup
  echo "$@"
  exit 1
}

. ../../../nvm.sh

# Sets the PATH for these tests to include the symlinks to the mocked binaries
export PATH=".:${PATH}"

TMP_DIR=$(mktemp -d)
CHROOT_WITH_ALPINE="$TMP_DIR/with_alpine"
CHROOT_WITHOUT_ALPINE="$TMP_DIR/without_alpine"

setup_chroot() {
  chroot_dir=$1

  # Directories
  mkdir -p "${chroot_dir}/etc"
  mkdir -p "${chroot_dir}/bin"
  mkdir -p "${chroot_dir}/usr/bin"
  mkdir -p "${chroot_dir}/lib64"
  mkdir -p "${chroot_dir}/dev"

  # Files and binaries
  cp ../../../nvm.sh "${chroot_dir}/"
  cp /bin/sh /usr/bin/dirname "${chroot_dir}/bin/"
  [ "${chroot_dir}" = "${CHROOT_WITH_ALPINE}" ] && touch "${chroot_dir}/etc/alpine-release"

  # Libraries
  for binary in /bin/sh /usr/bin/dirname; do
    for lib in $(ldd $binary | awk '{print $3}' | grep "^/"); do
      dir=$(dirname "${lib}")
      mkdir -p "${chroot_dir}${dir}"
      cp "${lib}" "${chroot_dir}${dir}/"
    done
  done

  # Dynamic linker
  cp /lib64/ld-linux-x86-64.so.2 "${chroot_dir}/lib64/"

  # /dev/null
  sudo mknod "${chroot_dir}/dev/null" c 1 3
}

setup_chroot "${CHROOT_WITH_ALPINE}"
setup_chroot "${CHROOT_WITHOUT_ALPINE}"

# Run tests in chroot environments
ARCH_WITH_ALPINE=$(sudo chroot "${CHROOT_WITH_ALPINE}" /bin/sh -c ". ./nvm.sh && nvm_get_arch")
[ "${ARCH_WITH_ALPINE}" = "x64-musl" ] || die "Expected x64-musl for alpine environment but got ${ARCH_WITH_ALPINE}"

ARCH_WITHOUT_ALPINE=$(sudo chroot "${CHROOT_WITHOUT_ALPINE}" /bin/sh -c ". ./nvm.sh && nvm_get_arch")
[ "${ARCH_WITHOUT_ALPINE}" != "x64-musl" ] || die "Did not expect x64-musl for non-alpine environment"

# Run tests for nvm ls-remote
test_default_ls_remote() {
  mock_response='N/A'
  result=$(NVM_NODEJS_ORG_MIRROR='http://nonexistent-url' nvm ls-remote 18)
  if [ "${result}" = "${mock_response}" ]; then
    die "Test failed: Expected '${mock_response}' for but got '${result}'"
  else
    echo "Test passed"
  fi
}

test_unofficial_mirror_ls_remote() {
  mock_response='v18.18.0   (LTS: Hydrogen)'
  result=$(NVM_NODEJS_ORG_MIRROR='https://unofficial-builds.nodejs.org/download/release' nvm ls-remote 18.18.0 | sed -e 's/^[[:space:]]*//')
  result=$(echo "${result}" | sed 's/\x1b\[[0-9;]*m//g')

  if [ "${result}" = "${mock_response}" ]; then
    echo "Test passed"
  else
    die "Test failed: Expected '${mock_response}' but got '${result}'"
  fi
}

test_default_ls_remote
test_unofficial_mirror_ls_remote

cleanup
