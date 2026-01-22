#!/bin/sh

cleanup() {
  [ -d "${tmp_dir}" ] && rm -rf "${tmp_dir}"
  [ -d "${NVM_DIR}" ] && rm -rf "${NVM_DIR}"
  unset -f die cleanup test_archi nvm_supports_xz
  unset NVM_DIR tmp_dir version archi
}

die() { echo "$@" ; cleanup ; exit 1; }

test_archi() {
  local os
  os="$1"
  local version
  version="$2"
  local archi
  archi="$os-$3"
  local node
  node="$4"
  local ext
  ext="$5"
  local command
  command="$6"
  local command_option
  command_option="$7"
  local node_dir
  node_dir="${tmp_dir}/node-${version}-${archi}"
  local node_path
  node_path="${node_dir}/${node}"

  # Create tarball
  mkdir -p "$(dirname "${node_path}")"
  echo "node ${version}" > "${node_path}"
  (cd "${tmp_dir}" && "${command}" "${command_option}" "${node_dir}.${ext}" "node-${version}-${archi}")
  [ -f "${node_dir}.${ext}" ] || die "Unable to create fake ${ext} file"

  # Extract it
  nvm_install_binary_extract "$os" "$version" "$(expr "${version}" : '.\(.*\)')" "${node_dir}.$ext" "${tmp_dir}/files"
  [ "$(cat "${NVM_DIR}/versions/node/${version}/bin/node")" = "node ${version}" ] || die "Unable to extract ${ext} file"
}

\. ../../../nvm.sh

set -ex

# nvm_install_binary_extract is available
type nvm_install_binary_extract > /dev/null 2>&1 || die 'nvm_install_binary_extract is not available'

NVM_DIR=$(mktemp -d)
tmp_dir=$(mktemp -d)
if [ -z "${NVM_DIR}" ] || [ -z "${tmp_dir}" ]; then
  die 'Unable to create temporary folder'
fi

# Test windows zip
# TODO: enable this
# test_archi 'win' 'v15.6.0' 'x64' 'node' 'zip' 'zip' '-qr'

# Test linux tar.xz
test_archi 'linux' 'v14.15.4' 'x64' 'bin/node' 'tar.xz' 'tar' '-cJf'

nvm_supports_xz() {
  return 1
}

# Test linux tar.gz
test_archi 'linux' 'v12.9.0' 'x64' 'bin/node' 'tar.gz' 'tar' '-czf'

cleanup
