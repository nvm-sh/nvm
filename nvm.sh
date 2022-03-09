# Node Version Manager
# Implemented as a POSIX-compliant function
# Should work on sh, dash, bash, ksh, zsh
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

# "local" warning, quote expansion warning, sed warning, `local` warning
# shellcheck disable=SC2039,SC2016,SC2001,SC3043
{ # this ensures the entire script is downloaded #

# shellcheck disable=SC3028
NVM_SCRIPT_SOURCE="$_"

nvm_is_zsh() {
  [ -n "${ZSH_VERSION-}" ]
}

nvm_stdout_is_terminal() {
  [ -t 1 ]
}

nvm_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

nvm_echo_with_colors() {
  command printf %b\\n "$*" 2>/dev/null
}

nvm_cd() {
  \cd "$@"
}

nvm_err() {
  >&2 nvm_echo "$@"
}

nvm_err_with_colors() {
  >&2 nvm_echo_with_colors "$@"
}

nvm_grep() {
  GREP_OPTIONS='' command grep "$@"
}

nvm_has() {
  type "${1-}" >/dev/null 2>&1
}

nvm_has_non_aliased() {
  nvm_has "${1-}" && ! nvm_is_alias "${1-}"
}

nvm_is_alias() {
  # this is intentionally not "command alias" so it works in zsh.
  \alias "${1-}" >/dev/null 2>&1
}

nvm_command_info() {
  local NVM_LOCAL_COMMAND
  local NVM_LOCAL_INFO
  NVM_LOCAL_COMMAND="${1}"
  if type "${NVM_LOCAL_COMMAND}" | nvm_grep -q hashed; then
    NVM_LOCAL_INFO="$(type "${NVM_LOCAL_COMMAND}" | command sed -E 's/\(|\)//g' | command awk '{print $4}')"
  elif type "${NVM_LOCAL_COMMAND}" | nvm_grep -q aliased; then
    # shellcheck disable=SC2230
    NVM_LOCAL_INFO="$(which "${NVM_LOCAL_COMMAND}") ($(type "${NVM_LOCAL_COMMAND}" | command awk '{ $1=$2=$3=$4="" ;print }' | command sed -e 's/^\ *//g' -Ee "s/\`|'//g"))"
  elif type "${NVM_LOCAL_COMMAND}" | nvm_grep -q "^${NVM_LOCAL_COMMAND} is an alias for"; then
    # shellcheck disable=SC2230
    NVM_LOCAL_INFO="$(which "${NVM_LOCAL_COMMAND}") ($(type "${NVM_LOCAL_COMMAND}" | command awk '{ $1=$2=$3=$4=$5="" ;print }' | command sed 's/^\ *//g'))"
  elif type "${NVM_LOCAL_COMMAND}" | nvm_grep -q "^${NVM_LOCAL_COMMAND} is \\/"; then
    NVM_LOCAL_INFO="$(type "${NVM_LOCAL_COMMAND}" | command awk '{print $3}')"
  else
    NVM_LOCAL_INFO="$(type "${NVM_LOCAL_COMMAND}")"
  fi
  nvm_echo "${NVM_LOCAL_INFO}"
}

nvm_has_colors() {
  local NVM_LOCAL_NUM_COLORS
  if nvm_has tput; then
    NVM_LOCAL_NUM_COLORS="$(tput -T "${TERM:-vt100}" colors)"
  fi
  [ "${NVM_LOCAL_NUM_COLORS:--1}" -ge 8 ]
}

nvm_curl_libz_support() {
  curl -V 2>/dev/null | nvm_grep "^Features:" | nvm_grep -q "libz"
}

nvm_curl_use_compression() {
  nvm_curl_libz_support && nvm_version_greater_than_or_equal_to "$(nvm_curl_version)" 7.21.0
}

nvm_get_latest() {
  local NVM_LOCAL_LATEST_URL
  local NVM_LOCAL_CURL_COMPRESSED_FLAG
  if nvm_has "curl"; then
    if nvm_curl_use_compression; then
      NVM_LOCAL_CURL_COMPRESSED_FLAG="--compressed"
    fi
    NVM_LOCAL_LATEST_URL="$(curl ${NVM_LOCAL_CURL_COMPRESSED_FLAG:-} -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)"
  elif nvm_has "wget"; then
    NVM_LOCAL_LATEST_URL="$(wget -q https://latest.nvm.sh --server-response -O /dev/null 2>&1 | command awk '/^  Location: /{DEST=$2} END{ print DEST }')"
  else
    nvm_err 'nvm needs curl or wget to proceed.'
    return 1
  fi
  if [ -z "${NVM_LOCAL_LATEST_URL}" ]; then
    nvm_err "https://latest.nvm.sh did not redirect to the latest release on GitHub"
    return 2
  fi
  nvm_echo "${NVM_LOCAL_LATEST_URL##*/}"
}

nvm_download() {
  local NVM_LOCAL_CURL_COMPRESSED_FLAG
  if nvm_has "curl"; then
    if nvm_curl_use_compression; then
      NVM_LOCAL_CURL_COMPRESSED_FLAG="--compressed"
    fi
    curl --fail ${NVM_LOCAL_CURL_COMPRESSED_FLAG:-} -q "$@"
  elif nvm_has "wget"; then
    # Emulate curl with wget
    ARGS=$(nvm_echo "$@" | command sed -e 's/--progress-bar /--progress=bar /' \
                            -e 's/--compressed //' \
                            -e 's/--fail //' \
                            -e 's/-L //' \
                            -e 's/-I /--server-response /' \
                            -e 's/-s /-q /' \
                            -e 's/-sS /-nv /' \
                            -e 's/-o /-O /' \
                            -e 's/-C - /-c /')
    # shellcheck disable=SC2086
    eval wget ${ARGS}
  fi
}

nvm_has_system_node() {
  [ "$(nvm deactivate >/dev/null 2>&1 && command -v node)" != '' ]
}

nvm_has_system_iojs() {
  [ "$(nvm deactivate >/dev/null 2>&1 && command -v iojs)" != '' ]
}

nvm_is_version_installed() {
  if [ -z "${1-}" ]; then
    return 1
  fi
  local NVM_LOCAL_NODE_BINARY
  NVM_LOCAL_NODE_BINARY='node'
  if [ "_$(nvm_get_os)" = '_win' ]; then
    NVM_LOCAL_NODE_BINARY='node.exe'
  fi
  if [ -x "$(nvm_version_path "$1" 2>/dev/null)/bin/${NVM_LOCAL_NODE_BINARY}" ]; then
    return 0
  fi
  return 1
}

nvm_print_npm_version() {
  if nvm_has "npm"; then
    command printf " (npm v$(npm --version 2>/dev/null))"
  fi
}

nvm_install_latest_npm() {
  nvm_echo 'Attempting to upgrade to the latest working version of npm...'
  local NVM_LOCAL_NODE_VERSION
  NVM_LOCAL_NODE_VERSION="$(nvm_strip_iojs_prefix "$(nvm_ls_current)")"
  if [ "${NVM_LOCAL_NODE_VERSION}" = 'system' ]; then
    NVM_LOCAL_NODE_VERSION="$(node --version)"
  elif [ "${NVM_LOCAL_NODE_VERSION}" = 'none' ]; then
    nvm_echo "Detected node version ${NVM_LOCAL_NODE_VERSION}, npm version v${LOCAL_NPM_VERSION}"
    NVM_LOCAL_NODE_VERSION=''
  fi
  if [ -z "${NVM_LOCAL_NODE_VERSION}" ]; then
    nvm_err 'Unable to obtain node version.'
    return 1
  fi
  local LOCAL_NPM_VERSION
  LOCAL_NPM_VERSION="$(npm --version 2>/dev/null)"
  if [ -z "${LOCAL_NPM_VERSION}" ]; then
    nvm_err 'Unable to obtain npm version.'
    return 2
  fi

  local NVM_LOCAL_TOOL_NPM
  NVM_LOCAL_TOOL_NPM='npm'
  if [ "${NVM_DEBUG-}" = 1 ]; then
    nvm_echo "Detected node version ${NVM_LOCAL_NODE_VERSION}, npm version v${LOCAL_NPM_VERSION}"
    NVM_LOCAL_TOOL_NPM='nvm_echo npm'
  fi

  local NVM_LOCAL_IS_0_6
  NVM_LOCAL_IS_0_6=0
  if nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 0.6.0 && nvm_version_greater 0.7.0 "${NVM_LOCAL_NODE_VERSION}"; then
    NVM_LOCAL_IS_0_6=1
  fi
  local NVM_LOCAL_IS_0_9
  NVM_LOCAL_IS_0_9=0
  if nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 0.9.0 && nvm_version_greater 0.10.0 "${NVM_LOCAL_NODE_VERSION}"; then
    NVM_LOCAL_IS_0_9=1
  fi

  if [ ${NVM_LOCAL_IS_0_6} -eq 1 ]; then
    nvm_echo '* `node` v0.6.x can only upgrade to `npm` v1.3.x'
    ${NVM_LOCAL_TOOL_NPM} install -g npm@1.3
  elif [ ${NVM_LOCAL_IS_0_9} -eq 0 ]; then
    # node 0.9 breaks here, for some reason
    if nvm_version_greater_than_or_equal_to "${LOCAL_NPM_VERSION}" 1.0.0 && nvm_version_greater 2.0.0 "${LOCAL_NPM_VERSION}"; then
      nvm_echo '* `npm` v1.x needs to first jump to `npm` v1.4.28 to be able to upgrade further'
      ${NVM_LOCAL_TOOL_NPM} install -g npm@1.4.28
    elif nvm_version_greater_than_or_equal_to "${LOCAL_NPM_VERSION}" 2.0.0 && nvm_version_greater 3.0.0 "${LOCAL_NPM_VERSION}"; then
      nvm_echo '* `npm` v2.x needs to first jump to the latest v2 to be able to upgrade further'
      ${NVM_LOCAL_TOOL_NPM} install -g npm@2
    fi
  fi

  if [ ${NVM_LOCAL_IS_0_9} -eq 1 ] || [ ${NVM_LOCAL_IS_0_6} -eq 1 ]; then
    nvm_echo '* node v0.6 and v0.9 are unable to upgrade further'
  elif nvm_version_greater 1.1.0 "${NVM_LOCAL_NODE_VERSION}"; then
    nvm_echo '* `npm` v4.5.x is the last version that works on `node` versions < v1.1.0'
    ${NVM_LOCAL_TOOL_NPM} install -g npm@4.5
  elif nvm_version_greater 4.0.0 "${NVM_LOCAL_NODE_VERSION}"; then
    nvm_echo '* `npm` v5 and higher do not work on `node` versions below v4.0.0'
    ${NVM_LOCAL_TOOL_NPM} install -g npm@4
  elif [ ${NVM_LOCAL_IS_0_9} -eq 0 ] && [ ${NVM_LOCAL_IS_0_6} -eq 0 ]; then
    local NVM_LOCAL_IS_4_4_OR_BELOW
    NVM_LOCAL_IS_4_4_OR_BELOW=0
    if nvm_version_greater 4.5.0 "${NVM_LOCAL_NODE_VERSION}"; then
      NVM_LOCAL_IS_4_4_OR_BELOW=1
    fi

    local NVM_LOCAL_IS_5_OR_ABOVE
    NVM_LOCAL_IS_5_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_4_4_OR_BELOW} -eq 0 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 5.0.0; then
      NVM_LOCAL_IS_5_OR_ABOVE=1
    fi

    local NVM_LOCAL_IS_6_OR_ABOVE
    NVM_LOCAL_IS_6_OR_ABOVE=0
    local NVM_LOCAL_IS_6_2_OR_ABOVE
    NVM_LOCAL_IS_6_2_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_5_OR_ABOVE} -eq 1 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 6.0.0; then
      NVM_LOCAL_IS_6_OR_ABOVE=1
      if nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 6.2.0; then
        NVM_LOCAL_IS_6_2_OR_ABOVE=1
      fi
    fi

    local NVM_LOCAL_IS_9_OR_ABOVE
    NVM_LOCAL_IS_9_OR_ABOVE=0
    local NVM_LOCAL_IS_9_3_OR_ABOVE
    NVM_LOCAL_IS_9_3_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_6_2_OR_ABOVE} -eq 1 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 9.0.0; then
      NVM_LOCAL_IS_9_OR_ABOVE=1
      if nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 9.3.0; then
        NVM_LOCAL_IS_9_3_OR_ABOVE=1
      fi
    fi

    local NVM_LOCAL_IS_10_OR_ABOVE
    NVM_LOCAL_IS_10_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_9_3_OR_ABOVE} -eq 1 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 10.0.0; then
      NVM_LOCAL_IS_10_OR_ABOVE=1
    fi
    local NVM_LOCAL_IS_12_LTS_OR_ABOVE
    NVM_LOCAL_IS_12_LTS_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_10_OR_ABOVE} -eq 1 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 12.13.0; then
      NVM_LOCAL_IS_12_LTS_OR_ABOVE=1
    fi
    local NVM_LOCAL_IS_13_OR_ABOVE
    NVM_LOCAL_IS_13_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_12_LTS_OR_ABOVE} -eq 1 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 13.0.0; then
      NVM_LOCAL_IS_13_OR_ABOVE=1
    fi
    local NVM_LOCAL_IS_14_LTS_OR_ABOVE
    NVM_LOCAL_IS_14_LTS_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_13_OR_ABOVE} -eq 1 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 14.15.0; then
      NVM_LOCAL_IS_14_LTS_OR_ABOVE=1
    fi
    local NVM_LOCAL_IS_15_OR_ABOVE
    NVM_LOCAL_IS_15_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_14_LTS_OR_ABOVE} -eq 1 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 15.0.0; then
      NVM_LOCAL_IS_15_OR_ABOVE=1
    fi
    local NVM_LOCAL_IS_16_OR_ABOVE
    NVM_LOCAL_IS_16_OR_ABOVE=0
    if [ ${NVM_LOCAL_IS_15_OR_ABOVE} -eq 1 ] && nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" 16.0.0; then
      NVM_LOCAL_IS_16_OR_ABOVE=1
    fi

    if [ ${NVM_LOCAL_IS_4_4_OR_BELOW} -eq 1 ] || {
      [ ${NVM_LOCAL_IS_5_OR_ABOVE} -eq 1 ] && nvm_version_greater 5.10.0 "${NVM_LOCAL_NODE_VERSION}"; \
    }; then
      nvm_echo '* `npm` `v5.3.x` is the last version that works on `node` 4.x versions below v4.4, or 5.x versions below v5.10, due to `Buffer.alloc`'
      ${NVM_LOCAL_TOOL_NPM} install -g npm@5.3
    elif [ ${NVM_LOCAL_IS_4_4_OR_BELOW} -eq 0 ] && nvm_version_greater 4.7.0 "${NVM_LOCAL_NODE_VERSION}"; then
      nvm_echo '* `npm` `v5.4.1` is the last version that works on `node` `v4.5` and `v4.6`'
      ${NVM_LOCAL_TOOL_NPM} install -g npm@5.4.1
    elif [ ${NVM_LOCAL_IS_6_OR_ABOVE} -eq 0 ]; then
      nvm_echo '* `npm` `v5.x` is the last version that works on `node` below `v6.0.0`'
      ${NVM_LOCAL_TOOL_NPM} install -g npm@5
    elif \
      { [ ${NVM_LOCAL_IS_6_OR_ABOVE} -eq 1 ] && [ ${NVM_LOCAL_IS_6_2_OR_ABOVE} -eq 0 ]; } \
      || { [ ${NVM_LOCAL_IS_9_OR_ABOVE} -eq 1 ] && [ ${NVM_LOCAL_IS_9_3_OR_ABOVE} -eq 0 ]; } \
    ; then
      nvm_echo '* `npm` `v6.9` is the last version that works on `node` `v6.0.x`, `v6.1.x`, `v9.0.x`, `v9.1.x`, or `v9.2.x`'
      ${NVM_LOCAL_TOOL_NPM} install -g npm@6.9
    elif [ ${NVM_LOCAL_IS_10_OR_ABOVE} -eq 0 ]; then
      nvm_echo '* `npm` `v6.x` is the last version that works on `node` below `v10.0.0`'
      ${NVM_LOCAL_TOOL_NPM} install -g npm@6
    elif \
      [ ${NVM_LOCAL_IS_12_LTS_OR_ABOVE} -eq 0 ] \
      || { [ ${NVM_LOCAL_IS_13_OR_ABOVE} -eq 1 ] && [ ${NVM_LOCAL_IS_14_LTS_OR_ABOVE} -eq 0 ]; } \
      || { [ ${NVM_LOCAL_IS_15_OR_ABOVE} -eq 1 ] && [ ${NVM_LOCAL_IS_16_OR_ABOVE} -eq 0 ]; } \
    ; then
      nvm_echo '* `npm` `v7.x` is the last version that works on `node` `v13`, `v15`, below `v12.13`, or `v14.0` - `v14.15`'
      ${NVM_LOCAL_TOOL_NPM} install -g npm@7
    else
      nvm_echo '* Installing latest `npm`; if this does not work on your node version, please report a bug!'
      ${NVM_LOCAL_TOOL_NPM} install -g npm
    fi
  fi
  nvm_echo "* npm upgraded to: v$(npm --version 2>/dev/null)"
}

# Make zsh glob matching behave same as bash
# This fixes the "zsh: no matches found" errors
if [ -z "${NVM_CD_FLAGS-}" ]; then
  export NVM_CD_FLAGS=''
fi
if nvm_is_zsh; then
  NVM_CD_FLAGS="-q"
fi

# Auto detect the NVM_DIR when not set
if [ -z "${NVM_DIR-}" ]; then
  # shellcheck disable=SC2128
  if [ -n "${BASH_SOURCE-}" ]; then
    # shellcheck disable=SC2169,SC3054
    NVM_SCRIPT_SOURCE="${BASH_SOURCE[0]}"
  fi
  NVM_DIR="$(nvm_cd ${NVM_CD_FLAGS} "$(dirname "${NVM_SCRIPT_SOURCE:-$0}")" >/dev/null && \pwd)"
  export NVM_DIR
else
  # https://unix.stackexchange.com/a/198289
  case ${NVM_DIR} in
    *[!/]*/)
      NVM_DIR="${NVM_DIR%"${NVM_DIR##*[!/]}"}"
      export NVM_DIR
      nvm_err "Warning: \${NVM_DIR} should not have trailing slashes"
    ;;
  esac
fi
unset NVM_SCRIPT_SOURCE 2>/dev/null

nvm_tree_contains_path() {
  local NVM_LOCAL_TREE
  NVM_LOCAL_TREE="${1-}"
  local NVM_LOCAL_NODE_PATH
  NVM_LOCAL_NODE_PATH="${2-}"

  if [ "@${NVM_LOCAL_TREE}@" = "@@" ] || [ "@${NVM_LOCAL_NODE_PATH}@" = "@@" ]; then
    nvm_err "both the tree and the node path are required"
    return 2
  fi

  local NVM_LOCAL_PREVIOUS_PATHDIR
  NVM_LOCAL_PREVIOUS_PATHDIR="${NVM_LOCAL_NODE_PATH}"
  local NVM_LOCAL_PATHDIR
  NVM_LOCAL_PATHDIR=$(dirname "${NVM_LOCAL_PREVIOUS_PATHDIR}")
  while [ "${NVM_LOCAL_PATHDIR}" != '' ] && [ "${NVM_LOCAL_PATHDIR}" != '.' ] && [ "${NVM_LOCAL_PATHDIR}" != '/' ] &&
      [ "${NVM_LOCAL_PATHDIR}" != "${NVM_LOCAL_TREE}" ] && [ "${NVM_LOCAL_PATHDIR}" != "${NVM_LOCAL_PREVIOUS_PATHDIR}" ]; do
    NVM_LOCAL_PREVIOUS_PATHDIR="${NVM_LOCAL_PATHDIR}"
    NVM_LOCAL_PATHDIR=$(dirname "${NVM_LOCAL_PREVIOUS_PATHDIR}")
  done
  [ "${NVM_LOCAL_PATHDIR}" = "${NVM_LOCAL_TREE}" ]
}

nvm_find_project_dir() {
  local NVM_LOCAL_PATH
  NVM_LOCAL_PATH="${PWD}"
  while [ "${NVM_LOCAL_PATH}" != "" ] && [ ! -f "${NVM_LOCAL_PATH}/package.json" ] && [ ! -d "${NVM_LOCAL_PATH}/node_modules" ]; do
    NVM_LOCAL_PATH=${NVM_LOCAL_PATH%/*}
  done
  nvm_echo "${NVM_LOCAL_PATH}"
}

# Traverse up in directory tree to find containing folder
nvm_find_up() {
  local NVM_LOCAL_PATH
  NVM_LOCAL_PATH="${PWD}"
  while [ "${NVM_LOCAL_PATH}" != "" ] && [ ! -f "${NVM_LOCAL_PATH}/${1-}" ]; do
    NVM_LOCAL_PATH=${NVM_LOCAL_PATH%/*}
  done
  nvm_echo "${NVM_LOCAL_PATH}"
}

nvm_find_nvmrc() {
  local NVM_LOCAL_DIR
  NVM_LOCAL_DIR="$(nvm_find_up '.nvmrc')"
  if [ -e "${NVM_LOCAL_DIR}/.nvmrc" ]; then
    nvm_echo "${NVM_LOCAL_DIR}/.nvmrc"
  fi
}

# Obtain nvm version from rc file
nvm_rc_version() {
  export NVM_RC_VERSION=''
  local NVM_LOCAL_RC_PATH
  NVM_LOCAL_RC_PATH="$(nvm_find_nvmrc)"
  if [ ! -e "${NVM_LOCAL_RC_PATH}" ]; then
    if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
      nvm_err "No .nvmrc file found"
    fi
    return 1
  fi
  NVM_RC_VERSION="$(command head -n 1 "${NVM_LOCAL_RC_PATH}" | command tr -d '\r')" || command printf ''
  if [ -z "${NVM_RC_VERSION}" ]; then
    if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
      nvm_err "Warning: empty .nvmrc file found at \"${NVM_LOCAL_RC_PATH}\""
    fi
    return 2
  fi
  if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
    nvm_echo "Found '${NVM_LOCAL_RC_PATH}' with version <${NVM_RC_VERSION}>"
  fi
}

nvm_clang_version() {
  clang --version | command awk '{ if ($2 == "version") print $3; else if ($3 == "version") print $4 }' | command sed 's/-.*$//g'
}

nvm_curl_version() {
  curl -V | command awk '{ if ($1 == "curl") print $2 }' | command sed 's/-.*$//g'
}

nvm_version_greater() {
  command awk 'BEGIN {
    if (ARGV[1] == "" || ARGV[2] == "") exit(1)
    split(ARGV[1], a, /\./);
    split(ARGV[2], b, /\./);
    for (i=1; i<=3; i++) {
      if (a[i] && a[i] !~ /^[0-9]+$/) exit(2);
      if (b[i] && b[i] !~ /^[0-9]+$/) { exit(0); }
      if (a[i] < b[i]) exit(3);
      else if (a[i] > b[i]) exit(0);
    }
    exit(4)
  }' "${1#v}" "${2#v}"
}

nvm_version_greater_than_or_equal_to() {
  command awk 'BEGIN {
    if (ARGV[1] == "" || ARGV[2] == "") exit(1)
    split(ARGV[1], a, /\./);
    split(ARGV[2], b, /\./);
    for (i=1; i<=3; i++) {
      if (a[i] && a[i] !~ /^[0-9]+$/) exit(2);
      if (a[i] < b[i]) exit(3);
      else if (a[i] > b[i]) exit(0);
    }
    exit(0)
  }' "${1#v}" "${2#v}"
}

nvm_version_dir() {
  local NVM_LOCAL_WHICH_DIR
  NVM_LOCAL_WHICH_DIR="${1-}"
  if [ -z "${NVM_LOCAL_WHICH_DIR}" ] || [ "${NVM_LOCAL_WHICH_DIR}" = "new" ]; then
    nvm_echo "${NVM_DIR}/versions/node"
  elif [ "_${NVM_LOCAL_WHICH_DIR}" = "_iojs" ]; then
    nvm_echo "${NVM_DIR}/versions/io.js"
  elif [ "_${NVM_LOCAL_WHICH_DIR}" = "_old" ]; then
    nvm_echo "${NVM_DIR}"
  else
    nvm_err 'unknown version dir'
    return 3
  fi
}

nvm_alias_path() {
  nvm_echo "$(nvm_version_dir old)/alias"
}

nvm_version_path() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${1-}"
  if [ -z "${NVM_LOCAL_VERSION}" ]; then
    nvm_err 'version is required'
    return 3
  elif nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
    nvm_echo "$(nvm_version_dir iojs)/$(nvm_strip_iojs_prefix "${NVM_LOCAL_VERSION}")"
  elif nvm_version_greater 0.12.0 "${NVM_LOCAL_VERSION}"; then
    nvm_echo "$(nvm_version_dir old)/${NVM_LOCAL_VERSION}"
  else
    nvm_echo "$(nvm_version_dir new)/${NVM_LOCAL_VERSION}"
  fi
}

nvm_ensure_version_installed() {
  local NVM_LOCAL_PROVIDED_VERSION
  NVM_LOCAL_PROVIDED_VERSION="${1-}"
  if [ "${NVM_LOCAL_PROVIDED_VERSION}" = 'system' ]; then
    if nvm_has_system_iojs || nvm_has_system_node; then
      return 0
    fi
    nvm_err "N/A: no system version of node/io.js is installed."
    return 1
  fi
  local NVM_LOCAL_VERSION
  local NVM_LOCAL_EXIT_CODE
  NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_PROVIDED_VERSION}")"
  NVM_LOCAL_EXIT_CODE="$?"
  if [ "${NVM_LOCAL_EXIT_CODE}" != "0" ] || ! nvm_is_version_installed "${NVM_LOCAL_VERSION}"; then
    if NVM_LOCAL_ALIAS_VERSION="$(nvm_resolve_alias "${NVM_LOCAL_PROVIDED_VERSION}")"; then
      nvm_err "N/A: version \"${NVM_LOCAL_PROVIDED_VERSION} -> ${NVM_LOCAL_ALIAS_VERSION}\" is not yet installed."
    else
      local NVM_LOCAL_PREFIXED_VERSION
      NVM_LOCAL_PREFIXED_VERSION="$(nvm_ensure_version_prefix "${NVM_LOCAL_PROVIDED_VERSION}")"
      nvm_err "N/A: version \"${NVM_LOCAL_PREFIXED_VERSION:-${NVM_LOCAL_PROVIDED_VERSION}}\" is not yet installed."
    fi
    nvm_err ""
    nvm_err "You need to run \"nvm install ${NVM_LOCAL_PROVIDED_VERSION}\" to install it before using it."
    return 1
  fi
}

# Expand a version using the version cache
nvm_version() {
  local NVM_LOCAL_PATTERN
  NVM_LOCAL_PATTERN="${1-}"
  local NVM_LOCAL_VERSION
  # The default version is the current one
  if [ -z "${NVM_LOCAL_PATTERN}" ]; then
    NVM_LOCAL_PATTERN='current'
  fi

  if [ "${NVM_LOCAL_PATTERN}" = "current" ]; then
    nvm_ls_current
    return $?
  fi

  local NVM_LOCAL_NODE_PREFIX
  NVM_LOCAL_NODE_PREFIX="$(nvm_node_prefix)"
  case "_${NVM_LOCAL_PATTERN}" in
    "_${NVM_LOCAL_NODE_PREFIX}" | "_${NVM_LOCAL_NODE_PREFIX}-")
      NVM_LOCAL_PATTERN="stable"
    ;;
  esac
  NVM_LOCAL_VERSION="$(nvm_ls "${NVM_LOCAL_PATTERN}" | command tail -1)"
  if [ -z "${NVM_LOCAL_VERSION}" ] || [ "_${NVM_LOCAL_VERSION}" = "_N/A" ]; then
    nvm_echo "N/A"
    return 3
  fi
  nvm_echo "${NVM_LOCAL_VERSION}"
}

nvm_remote_version() {
  local NVM_LOCAL_PATTERN
  NVM_LOCAL_PATTERN="${1-}"
  local NVM_LOCAL_VERSION
  if nvm_validate_implicit_alias "${NVM_LOCAL_PATTERN}" 2>/dev/null; then
    case "${NVM_LOCAL_PATTERN}" in
      "$(nvm_iojs_prefix)")
        NVM_LOCAL_VERSION="$(NVM_LTS="${NVM_LTS-}" nvm_ls_remote_iojs | command tail -1)" &&:
      ;;
      *)
        NVM_LOCAL_VERSION="$(NVM_LTS="${NVM_LTS-}" nvm_ls_remote "${NVM_LOCAL_PATTERN}")" &&:
      ;;
    esac
  else
    NVM_LOCAL_VERSION="$(NVM_LTS="${NVM_LTS-}" nvm_remote_versions "${NVM_LOCAL_PATTERN}" | command tail -1)"
  fi
  if [ -n "${NVM_VERSION_ONLY-}" ]; then
    command awk 'BEGIN {
      n = split(ARGV[1], a);
      print a[1]
    }' "${NVM_LOCAL_VERSION}"
  else
    nvm_echo "${NVM_LOCAL_VERSION}"
  fi
  if [ "${NVM_LOCAL_VERSION}" = 'N/A' ]; then
    return 3
  fi
}

nvm_remote_versions() {
  local NVM_LOCAL_IOJS_PREFIX
  NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_LOCAL_NODE_PREFIX
  NVM_LOCAL_NODE_PREFIX="$(nvm_node_prefix)"

  local NVM_LOCAL_PATTERN
  NVM_LOCAL_PATTERN="${1-}"

  local NVM_LOCAL_FLAVOR
  if [ -n "${NVM_LTS-}" ]; then
    NVM_LOCAL_FLAVOR="${NVM_LOCAL_NODE_PREFIX}"
  fi

  case "${NVM_LOCAL_PATTERN}" in
    "${NVM_LOCAL_IOJS_PREFIX}" | "io.js")
      NVM_LOCAL_FLAVOR="${NVM_LOCAL_IOJS_PREFIX}"
      unset NVM_LOCAL_PATTERN
    ;;
    "${NVM_LOCAL_NODE_PREFIX}")
      NVM_LOCAL_FLAVOR="${NVM_LOCAL_NODE_PREFIX}"
      unset NVM_LOCAL_PATTERN
    ;;
  esac

  if nvm_validate_implicit_alias "${NVM_LOCAL_PATTERN-}" 2>/dev/null; then
    nvm_err 'Implicit aliases are not supported in nvm_remote_versions.'
    return 1
  fi

  local NVM_LOCAL_LS_REMOTE_EXIT_CODE
  NVM_LOCAL_LS_REMOTE_EXIT_CODE=0
  local NVM_LOCAL_LS_REMOTE_PRE_MERGED_OUTPUT
  NVM_LOCAL_LS_REMOTE_PRE_MERGED_OUTPUT=''
  local NVM_LOCAL_LS_REMOTE_POST_MERGED_OUTPUT
  NVM_LOCAL_LS_REMOTE_POST_MERGED_OUTPUT=''
  if [ -z "${NVM_LOCAL_FLAVOR-}" ] || [ "${NVM_LOCAL_FLAVOR-}" = "${NVM_LOCAL_NODE_PREFIX}" ]; then
    local NVM_LOCAL_LS_REMOTE_OUTPUT
    # extra space is needed here to avoid weird behavior when `nvm_ls_remote` ends in a `*`
    NVM_LOCAL_LS_REMOTE_OUTPUT="$(NVM_LTS="${NVM_LTS-}" nvm_ls_remote "${NVM_LOCAL_PATTERN-}") " &&:
    NVM_LOCAL_LS_REMOTE_EXIT_CODE=$?
    # split output into two
    NVM_LOCAL_LS_REMOTE_PRE_MERGED_OUTPUT="${NVM_LOCAL_LS_REMOTE_OUTPUT%%v4\.0\.0*}"
    NVM_LOCAL_LS_REMOTE_POST_MERGED_OUTPUT="${NVM_LOCAL_LS_REMOTE_OUTPUT#"${NVM_LOCAL_LS_REMOTE_PRE_MERGED_OUTPUT}"}"
  fi

  local NVM_LOCAL_LS_REMOTE_IOJS_EXIT_CODE
  NVM_LOCAL_LS_REMOTE_IOJS_EXIT_CODE=0
  local NVM_LOCAL_LS_REMOTE_IOJS_OUTPUT
  NVM_LOCAL_LS_REMOTE_IOJS_OUTPUT=''
  if [ -z "${NVM_LTS-}" ] && {
    [ -z "${NVM_LOCAL_FLAVOR-}" ] || [ "${NVM_LOCAL_FLAVOR-}" = "${NVM_LOCAL_IOJS_PREFIX}" ];
  }; then
    NVM_LOCAL_LS_REMOTE_IOJS_OUTPUT=$(nvm_ls_remote_iojs "${NVM_LOCAL_PATTERN-}") &&:
    NVM_LOCAL_LS_REMOTE_IOJS_EXIT_CODE=$?
  fi

  # the `sed` removes both blank lines, and only-whitespace lines (see "weird behavior" ~19 lines up)
  local NVM_LOCAL_VERSIONS
  NVM_LOCAL_VERSIONS="$(nvm_echo "${NVM_LOCAL_LS_REMOTE_PRE_MERGED_OUTPUT}
${NVM_LOCAL_LS_REMOTE_IOJS_OUTPUT}
${NVM_LOCAL_LS_REMOTE_POST_MERGED_OUTPUT}" | nvm_grep -v "N/A" | command sed '/^ *$/d')"

  if [ -z "${NVM_LOCAL_VERSIONS}" ]; then
    nvm_echo 'N/A'
    return 3
  fi
  # the `sed` is to remove trailing whitespaces (see "weird behavior" ~25 lines up)
  nvm_echo "${NVM_LOCAL_VERSIONS}" | command sed 's/ *$//g'
  return ${NVM_LOCAL_LS_REMOTE_EXIT_CODE} || ${NVM_LOCAL_LS_REMOTE_IOJS_EXIT_CODE}
}

nvm_is_valid_version() {
  if nvm_validate_implicit_alias "${1-}" 2>/dev/null; then
    return 0
  fi
  case "${1-}" in
    "$(nvm_iojs_prefix)" | \
    "$(nvm_node_prefix)")
      return 0
    ;;
    *)
      local NVM_LOCAL_VERSION
      NVM_LOCAL_VERSION="$(nvm_strip_iojs_prefix "${1-}")"
      nvm_version_greater_than_or_equal_to "${NVM_LOCAL_VERSION}" 0
    ;;
  esac
}

nvm_normalize_version() {
  command awk 'BEGIN {
    split(ARGV[1], a, /\./);
    printf "%d%06d%06d\n", a[1], a[2], a[3];
    exit;
  }' "${1#v}"
}

nvm_normalize_lts() {
  local NVM_LOCAL_LTS
  NVM_LOCAL_LTS="${1-}"

  if [ "$(expr "${NVM_LOCAL_LTS}" : '^lts/-[1-9][0-9]*$')" -gt 0 ]; then
    local NVM_LOCAL_N
    NVM_LOCAL_N="$(echo "${NVM_LOCAL_LTS}" | cut -d '-' -f 2)"
    NVM_LOCAL_N=$((NVM_LOCAL_N+1))
    local NVM_LOCAL_ALIAS_DIR
    NVM_LOCAL_ALIAS_DIR="$(nvm_alias_path)"
    local NVM_LOCAL_RESULT
    NVM_LOCAL_RESULT="$(command ls "${NVM_LOCAL_ALIAS_DIR}/lts" | command tail -n "${NVM_LOCAL_N}" | command head -n 1)"
    if [ "${NVM_LOCAL_RESULT}" != '*' ]; then
      nvm_echo "lts/${NVM_LOCAL_RESULT}"
    else
      nvm_err 'That many LTS releases do not exist yet.'
      return 2
    fi
  else
    nvm_echo "${NVM_LOCAL_LTS}"
  fi
}

nvm_ensure_version_prefix() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="$(nvm_strip_iojs_prefix "${1-}" | command sed -e 's/^\([0-9]\)/v\1/g')"
  if nvm_is_iojs_version "${1-}"; then
    nvm_add_iojs_prefix "${NVM_LOCAL_VERSION}"
  else
    nvm_echo "${NVM_LOCAL_VERSION}"
  fi
}

nvm_format_version() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="$(nvm_ensure_version_prefix "${1-}")"
  local NVM_LOCAL_NUM_GROUPS
  NVM_LOCAL_NUM_GROUPS="$(nvm_num_version_groups "${NVM_LOCAL_VERSION}")"
  if [ "${NVM_LOCAL_NUM_GROUPS}" -lt 3 ]; then
    nvm_format_version "${NVM_LOCAL_VERSION%.}.0"
  else
    nvm_echo "${NVM_LOCAL_VERSION}" | command cut -f1-3 -d.
  fi
}

nvm_num_version_groups() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${1-}"
  NVM_LOCAL_VERSION="${NVM_LOCAL_VERSION#v}"
  NVM_LOCAL_VERSION="${NVM_LOCAL_VERSION%.}"
  if [ -z "${NVM_LOCAL_VERSION}" ]; then
    nvm_echo "0"
    return
  fi
  local NVM_LOCAL_NUM_DOTS
  NVM_LOCAL_NUM_DOTS=$(nvm_echo "${NVM_LOCAL_VERSION}" | command sed -e 's/[^\.]//g')
  local NVM_LOCAL_NUM_GROUPS
  NVM_LOCAL_NUM_GROUPS=".${NVM_LOCAL_NUM_DOTS}" # add extra dot, since it's (n - 1) dots at this point
  nvm_echo "${#NVM_LOCAL_NUM_GROUPS}"
}

nvm_strip_path() {
  if [ -z "${NVM_DIR-}" ]; then
    nvm_err '${NVM_DIR} not set!'
    return 1
  fi
  command printf %s "${1-}" | command awk -v NVM_DIR="${NVM_DIR}" -v RS=: '
  index($0, NVM_DIR) == 1 {
    path = substr($0, length(NVM_DIR) + 1)
    if (path ~ "^(/versions/[^/]*)?/[^/]*'"${2-}"'.*$") { next }
  }
  { print }' | command paste -s -d: -
}

nvm_change_path() {
  # if there’s no initial path, just return the supplementary path
  if [ -z "${1-}" ]; then
    nvm_echo "${3-}${2-}"
  # if the initial path doesn’t contain an nvm path, prepend the supplementary
  # path
  elif ! nvm_echo "${1-}" | nvm_grep -q "${NVM_DIR}/[^/]*${2-}" \
    && ! nvm_echo "${1-}" | nvm_grep -q "${NVM_DIR}/versions/[^/]*/[^/]*${2-}"; then
    nvm_echo "${3-}${2-}:${1-}"
  # if the initial path contains BOTH an nvm path (checked for above) and
  # that nvm path is preceded by a system binary path, just prepend the
  # supplementary path instead of replacing it.
  # https://github.com/nvm-sh/nvm/issues/1652#issuecomment-342571223
  elif nvm_echo "${1-}" | nvm_grep -Eq "(^|:)(/usr(/local)?)?${2-}:.*${NVM_DIR}/[^/]*${2-}" \
    || nvm_echo "${1-}" | nvm_grep -Eq "(^|:)(/usr(/local)?)?${2-}:.*${NVM_DIR}/versions/[^/]*/[^/]*${2-}"; then
    nvm_echo "${3-}${2-}:${1-}"
  # use sed to replace the existing nvm path with the supplementary path. This
  # preserves the order of the path.
  else
    nvm_echo "${1-}" | command sed \
      -e "s#${NVM_DIR}/[^/]*${2-}[^:]*#${3-}${2-}#" \
      -e "s#${NVM_DIR}/versions/[^/]*/[^/]*${2-}[^:]*#${3-}${2-}#"
  fi
}

nvm_binary_available() {
  # binaries started with node 0.8.6
  nvm_version_greater_than_or_equal_to "$(nvm_strip_iojs_prefix "${1-}")" v0.8.6
}

nvm_set_colors() {
  if [ "${#1}" -eq 5 ] && nvm_echo "$1" | nvm_grep -E "^[rRgGbBcCyYmMkKeW]{1,}$" 1>/dev/null; then
    local NVM_LOCAL_INSTALLED_COLOR
    local NVM_LOCAL_LTS_AND_SYSTEM_COLOR
    local NVM_LOCAL_CURRENT_COLOR
    local NVM_LOCAL_NOT_INSTALLED_COLOR
    local NVM_LOCAL_DEFAULT_COLOR

    NVM_LOCAL_INSTALLED_COLOR="$(echo "$1" | awk '{ print substr($0, 1, 1); }')"
    NVM_LOCAL_LTS_AND_SYSTEM_COLOR="$(echo "$1" | awk '{ print substr($0, 2, 1); }')"
    NVM_LOCAL_CURRENT_COLOR="$(echo "$1" | awk '{ print substr($0, 3, 1); }')"
    NVM_LOCAL_NOT_INSTALLED_COLOR="$(echo "$1" | awk '{ print substr($0, 4, 1); }')"
    NVM_LOCAL_DEFAULT_COLOR="$(echo "$1" | awk '{ print substr($0, 5, 1); }')"
    if ! nvm_has_colors; then
      nvm_echo "Setting colors to: ${NVM_LOCAL_INSTALLED_COLOR} ${NVM_LOCAL_LTS_AND_SYSTEM_COLOR} ${NVM_LOCAL_CURRENT_COLOR} ${NVM_LOCAL_NOT_INSTALLED_COLOR} ${NVM_LOCAL_DEFAULT_COLOR}"
      nvm_echo "WARNING: Colors may not display because they are not supported in this shell."
    else
      nvm_echo_with_colors "Setting colors to: \033[$(nvm_print_color_code "${NVM_LOCAL_INSTALLED_COLOR}") ${NVM_LOCAL_INSTALLED_COLOR}\033[$(nvm_print_color_code "${NVM_LOCAL_LTS_AND_SYSTEM_COLOR}") ${NVM_LOCAL_LTS_AND_SYSTEM_COLOR}\033[$(nvm_print_color_code "${NVM_LOCAL_CURRENT_COLOR}") ${NVM_LOCAL_CURRENT_COLOR}\033[$(nvm_print_color_code "${NVM_LOCAL_NOT_INSTALLED_COLOR}") ${NVM_LOCAL_NOT_INSTALLED_COLOR}\033[$(nvm_print_color_code "${NVM_LOCAL_DEFAULT_COLOR}") ${NVM_LOCAL_DEFAULT_COLOR}\033[0m"
    fi
    export NVM_COLORS="$1"
  else
    return 17
  fi
}

nvm_get_colors() {
  local NVM_LOCAL_COLOR
  local NVM_LOCAL_SYS_COLOR
  if [ -n "${NVM_COLORS-}" ]; then
    case $1 in
      1) NVM_LOCAL_COLOR=$(nvm_print_color_code "$(echo "${NVM_COLORS}" | awk '{ print substr($0, 1, 1); }')");;
      2) NVM_LOCAL_COLOR=$(nvm_print_color_code "$(echo "${NVM_COLORS}" | awk '{ print substr($0, 2, 1); }')");;
      3) NVM_LOCAL_COLOR=$(nvm_print_color_code "$(echo "${NVM_COLORS}" | awk '{ print substr($0, 3, 1); }')");;
      4) NVM_LOCAL_COLOR=$(nvm_print_color_code "$(echo "${NVM_COLORS}" | awk '{ print substr($0, 4, 1); }')");;
      5) NVM_LOCAL_COLOR=$(nvm_print_color_code "$(echo "${NVM_COLORS}" | awk '{ print substr($0, 5, 1); }')");;
      6)
        NVM_LOCAL_SYS_COLOR=$(nvm_print_color_code "$(echo "${NVM_COLORS}" | awk '{ print substr($0, 2, 1); }')")
        NVM_LOCAL_COLOR=$(nvm_echo "${NVM_LOCAL_SYS_COLOR}" | command tr '0;' '1;')
        ;;
      *)
        nvm_err "Invalid color index, ${1-}"
        return 1
      ;;
    esac
  else
    case $1 in
      1) NVM_LOCAL_COLOR='0;34m';;
      2) NVM_LOCAL_COLOR='0;33m';;
      3) NVM_LOCAL_COLOR='0;32m';;
      4) NVM_LOCAL_COLOR='0;31m';;
      5) NVM_LOCAL_COLOR='0;37m';;
      6) NVM_LOCAL_COLOR='1;33m';;
      *)
        nvm_err "Invalid color index, ${1-}"
        return 1
      ;;
    esac
  fi

  echo "${NVM_LOCAL_COLOR}"
}

nvm_print_color_code() {
  case "${1-}" in
    'r') nvm_echo '0;31m';;
    'R') nvm_echo '1;31m';;
    'g') nvm_echo '0;32m';;
    'G') nvm_echo '1;32m';;
    'b') nvm_echo '0;34m';;
    'B') nvm_echo '1;34m';;
    'c') nvm_echo '0;36m';;
    'C') nvm_echo '1;36m';;
    'm') nvm_echo '0;35m';;
    'M') nvm_echo '1;35m';;
    'y') nvm_echo '0;33m';;
    'Y') nvm_echo '1;33m';;
    'k') nvm_echo '0;30m';;
    'K') nvm_echo '1;30m';;
    'e') nvm_echo '0;37m';;
    'W') nvm_echo '1;37m';;
    *) nvm_err 'Invalid color code';
        return 1
    ;;
  esac
}

nvm_print_formatted_alias() {
  local NVM_LOCAL_ALIAS
  NVM_LOCAL_ALIAS="${1-}"
  local NVM_LOCAL_DEST
  NVM_LOCAL_DEST="${2-}"
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${3-}"
  if [ -z "${NVM_LOCAL_VERSION}" ]; then
    NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_DEST}")" ||:
  fi

  local NVM_LOCAL_INSTALLED_COLOR
  local NVM_LOCAL_SYSTEM_COLOR
  local NVM_LOCAL_CURRENT_COLOR
  local NVM_LOCAL_NOT_INSTALLED_COLOR
  local NVM_LOCAL_DEFAULT_COLOR
  local NVM_LOCAL_LTS_COLOR
  NVM_LOCAL_INSTALLED_COLOR=$(nvm_get_colors 1)
  NVM_LOCAL_SYSTEM_COLOR=$(nvm_get_colors 2)
  NVM_LOCAL_CURRENT_COLOR=$(nvm_get_colors 3)
  NVM_LOCAL_NOT_INSTALLED_COLOR=$(nvm_get_colors 4)
  NVM_LOCAL_DEFAULT_COLOR=$(nvm_get_colors 5)
  NVM_LOCAL_LTS_COLOR=$(nvm_get_colors 6)

  local NVM_LOCAL_DEST_FORMAT
  local NVM_LOCAL_ALIAS_FORMAT
  local NVM_LOCAL_VERSION_FORMAT
  NVM_LOCAL_DEST_FORMAT='%s'
  NVM_LOCAL_ALIAS_FORMAT='%s'
  NVM_LOCAL_VERSION_FORMAT='%s'

  local NVM_LOCAL_NEWLINE
  NVM_LOCAL_NEWLINE='\n'
  if [ "_${NVM_DEFAULT}" = '_true' ]; then
    NVM_LOCAL_NEWLINE=' (default)\n'
  fi

  local NVM_LOCAL_ARROW
  NVM_LOCAL_ARROW='->'
  if [ -z "${NVM_NO_COLORS}" ] && nvm_has_colors; then
    NVM_LOCAL_ARROW='\033[0;90m->\033[0m'
    if [ "_${NVM_DEFAULT}" = '_true' ]; then
      NVM_LOCAL_NEWLINE=" \033[${NVM_LOCAL_DEFAULT_COLOR}(default)\033[0m\n"
    fi
    if [ "_${NVM_LOCAL_VERSION}" = "_${NVM_LOCAL_CURRENT-}" ]; then
      NVM_LOCAL_ALIAS_FORMAT="\033[${NVM_LOCAL_CURRENT_COLOR}%s\033[0m"
      NVM_LOCAL_DEST_FORMAT="\033[${NVM_LOCAL_CURRENT_COLOR}%s\033[0m"
      NVM_LOCAL_VERSION_FORMAT="\033[${NVM_LOCAL_CURRENT_COLOR}%s\033[0m"
    elif nvm_is_version_installed "${NVM_LOCAL_VERSION}"; then
      NVM_LOCAL_ALIAS_FORMAT="\033[${NVM_LOCAL_INSTALLED_COLOR}%s\033[0m"
      NVM_LOCAL_DEST_FORMAT="\033[${NVM_LOCAL_INSTALLED_COLOR}%s\033[0m"
      NVM_LOCAL_VERSION_FORMAT="\033[${NVM_LOCAL_INSTALLED_COLOR}%s\033[0m"
    elif [ "${NVM_LOCAL_VERSION}" = '∞' ] || [ "${NVM_LOCAL_VERSION}" = 'N/A' ]; then
      NVM_LOCAL_ALIAS_FORMAT="\033[${NVM_LOCAL_NOT_INSTALLED_COLOR}%s\033[0m"
      NVM_LOCAL_DEST_FORMAT="\033[${NVM_LOCAL_NOT_INSTALLED_COLOR}%s\033[0m"
      NVM_LOCAL_VERSION_FORMAT="\033[${NVM_LOCAL_NOT_INSTALLED_COLOR}%s\033[0m"
    fi
    if [ "_${NVM_LTS-}" = '_true' ]; then
      NVM_LOCAL_ALIAS_FORMAT="\033[${NVM_LOCAL_LTS_COLOR}%s\033[0m"
    fi
    if [ "_${NVM_LOCAL_DEST%/*}" = "_lts" ]; then
      NVM_LOCAL_DEST_FORMAT="\033[${NVM_LOCAL_LTS_COLOR}%s\033[0m"
    fi
  elif [ "_${NVM_LOCAL_VERSION}" != '_∞' ] && [ "_${NVM_LOCAL_VERSION}" != '_N/A' ]; then
    NVM_LOCAL_VERSION_FORMAT='%s *'
  fi
  if [ "${NVM_LOCAL_DEST}" = "${NVM_LOCAL_VERSION}" ]; then
    command printf -- "${NVM_LOCAL_ALIAS_FORMAT} ${NVM_LOCAL_ARROW} ${NVM_LOCAL_VERSION_FORMAT}${NVM_LOCAL_NEWLINE}" "${NVM_LOCAL_ALIAS}" "${NVM_LOCAL_DEST}"
  else
    command printf -- "${NVM_LOCAL_ALIAS_FORMAT} ${NVM_LOCAL_ARROW} ${NVM_LOCAL_DEST_FORMAT} (${NVM_LOCAL_ARROW} ${NVM_LOCAL_VERSION_FORMAT})${NVM_LOCAL_NEWLINE}" "${NVM_LOCAL_ALIAS}" "${NVM_LOCAL_DEST}" "${NVM_LOCAL_VERSION}"
  fi
}

nvm_print_alias_path() {
  local NVM_LOCAL_ALIAS_DIR
  NVM_LOCAL_ALIAS_DIR="${1-}"
  if [ -z "${NVM_LOCAL_ALIAS_DIR}" ]; then
    nvm_err 'An alias dir is required.'
    return 1
  fi
  local NVM_LOCAL_ALIAS_PATH
  NVM_LOCAL_ALIAS_PATH="${2-}"
  if [ -z "${NVM_LOCAL_ALIAS_PATH}" ]; then
    nvm_err 'An alias path is required.'
    return 2
  fi
  local NVM_LOCAL_ALIAS
  NVM_LOCAL_ALIAS="${NVM_LOCAL_ALIAS_PATH##"${NVM_LOCAL_ALIAS_DIR}"\/}"
  local NVM_LOCAL_DEST
  NVM_LOCAL_DEST="$(nvm_alias "${NVM_LOCAL_ALIAS}" 2>/dev/null)" ||:
  if [ -n "${NVM_LOCAL_DEST}" ]; then
    NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_LTS="${NVM_LTS-}" NVM_DEFAULT=false nvm_print_formatted_alias "${NVM_LOCAL_ALIAS}" "${NVM_LOCAL_DEST}"
  fi
}

nvm_print_default_alias() {
  local NVM_LOCAL_ALIAS
  NVM_LOCAL_ALIAS="${1-}"
  if [ -z "${NVM_LOCAL_ALIAS}" ]; then
    nvm_err 'A default alias is required.'
    return 1
  fi
  local NVM_LOCAL_DEST
  NVM_LOCAL_DEST="$(nvm_print_implicit_alias local "${NVM_LOCAL_ALIAS}")"
  if [ -n "${NVM_LOCAL_DEST}" ]; then
    NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_DEFAULT=true nvm_print_formatted_alias "${NVM_LOCAL_ALIAS}" "${NVM_LOCAL_DEST}"
  fi
}

nvm_make_alias() {
  local NVM_LOCAL_ALIAS
  NVM_LOCAL_ALIAS="${1-}"
  if [ -z "${NVM_LOCAL_ALIAS}" ]; then
    nvm_err "an alias name is required"
    return 1
  fi
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${2-}"
  if [ -z "${NVM_LOCAL_VERSION}" ]; then
    nvm_err "an alias target version is required"
    return 2
  fi
  nvm_echo "${NVM_LOCAL_VERSION}" | tee "$(nvm_alias_path)/${NVM_LOCAL_ALIAS}" >/dev/null
}

nvm_list_aliases() {
  local NVM_LOCAL_ALIAS
  NVM_LOCAL_ALIAS="${1-}"

  local NVM_LOCAL_CURRENT
  NVM_LOCAL_CURRENT="$(nvm_ls_current)"
  local NVM_LOCAL_ALIAS_DIR
  NVM_LOCAL_ALIAS_DIR="$(nvm_alias_path)"
  command mkdir -p "${NVM_LOCAL_ALIAS_DIR}/lts"

  if [ "${NVM_LOCAL_ALIAS}" != "${NVM_LOCAL_ALIAS#lts/}" ]; then
    nvm_alias "${NVM_LOCAL_ALIAS}"
    return $?
  fi

  nvm_is_zsh && unsetopt local_options nomatch
  (
    local NVM_LOCAL_ALIAS_PATH
    for NVM_LOCAL_ALIAS_PATH in "${NVM_LOCAL_ALIAS_DIR}/${NVM_LOCAL_ALIAS}"*; do
      NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_LOCAL_CURRENT="${NVM_LOCAL_CURRENT}" nvm_print_alias_path "${NVM_LOCAL_ALIAS_DIR}" "${NVM_LOCAL_ALIAS_PATH}" &
    done
    wait
  ) | sort

  (
    local NVM_LOCAL_ALIAS_NAME
    for NVM_LOCAL_ALIAS_NAME in "$(nvm_node_prefix)" "stable" "unstable"; do
      {
        # shellcheck disable=SC2030,SC2031 # (https://github.com/koalaman/shellcheck/issues/2217)
        if [ ! -f "${NVM_LOCAL_ALIAS_DIR}/${NVM_LOCAL_ALIAS_NAME}" ] && { [ -z "${NVM_LOCAL_ALIAS}" ] || [ "${NVM_LOCAL_ALIAS_NAME}" = "${NVM_LOCAL_ALIAS}" ]; }; then
          NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_LOCAL_CURRENT="${NVM_LOCAL_CURRENT}" nvm_print_default_alias "${NVM_LOCAL_ALIAS_NAME}"
        fi
      } &
    done
    wait
    NVM_LOCAL_ALIAS_NAME="$(nvm_iojs_prefix)"
    # shellcheck disable=SC2030,SC2031 # (https://github.com/koalaman/shellcheck/issues/2217)
    if [ ! -f "${NVM_LOCAL_ALIAS_DIR}/${NVM_LOCAL_ALIAS_NAME}" ] && { [ -z "${NVM_LOCAL_ALIAS}" ] || [ "${NVM_LOCAL_ALIAS_NAME}" = "${NVM_LOCAL_ALIAS}" ]; }; then
      NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_LOCAL_CURRENT="${NVM_LOCAL_CURRENT}" nvm_print_default_alias "${NVM_LOCAL_ALIAS_NAME}"
    fi
  ) | sort

  (
    local NVM_LOCAL_LTS_ALIAS
    local NVM_LOCAL_ALIAS_PATH
    # shellcheck disable=SC2030,SC2031 # (https://github.com/koalaman/shellcheck/issues/2217)
    for NVM_LOCAL_ALIAS_PATH in "${NVM_LOCAL_ALIAS_DIR}/lts/${NVM_LOCAL_ALIAS}"*; do
      {
        NVM_LOCAL_LTS_ALIAS="$(NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_LTS=true nvm_print_alias_path "${NVM_LOCAL_ALIAS_DIR}" "${NVM_LOCAL_ALIAS_PATH}")"
        if [ -n "${NVM_LOCAL_LTS_ALIAS}" ]; then
          nvm_echo "${NVM_LOCAL_LTS_ALIAS}"
        fi
      } &
    done
    wait
  ) | sort
  return
}

nvm_alias() {
  local NVM_LOCAL_ALIAS
  NVM_LOCAL_ALIAS="${1-}"
  if [ -z "${NVM_LOCAL_ALIAS}" ]; then
    nvm_err 'An alias is required.'
    return 1
  fi
  NVM_LOCAL_ALIAS="$(nvm_normalize_lts "${NVM_LOCAL_ALIAS}")"

  if [ -z "${NVM_LOCAL_ALIAS}" ]; then
    return 2
  fi

  local NVM_LOCAL_ALIAS_PATH
  NVM_LOCAL_ALIAS_PATH="$(nvm_alias_path)/${NVM_LOCAL_ALIAS}"
  if [ ! -f "${NVM_LOCAL_ALIAS_PATH}" ]; then
    nvm_err 'Alias does not exist.'
    return 2
  fi

  command cat "${NVM_LOCAL_ALIAS_PATH}"
}

nvm_ls_current() {
  local NVM_LOCAL_LS_CURRENT_NODE_PATH
  if ! NVM_LOCAL_LS_CURRENT_NODE_PATH="$(command which node 2>/dev/null)"; then
    nvm_echo 'none'
  elif nvm_tree_contains_path "$(nvm_version_dir iojs)" "${NVM_LOCAL_LS_CURRENT_NODE_PATH}"; then
    nvm_add_iojs_prefix "$(iojs --version 2>/dev/null)"
  elif nvm_tree_contains_path "${NVM_DIR}" "${NVM_LOCAL_LS_CURRENT_NODE_PATH}"; then
    local NVM_LOCAL_VERSION
    NVM_LOCAL_VERSION="$(node --version 2>/dev/null)"
    if [ "${NVM_LOCAL_VERSION}" = "v0.6.21-pre" ]; then
      nvm_echo 'v0.6.21'
    else
      nvm_echo "${NVM_LOCAL_VERSION}"
    fi
  else
    nvm_echo 'system'
  fi
}

nvm_resolve_alias() {
  if [ -z "${1-}" ]; then
    return 1
  fi

  local NVM_LOCAL_PATTERN
  NVM_LOCAL_PATTERN="${1-}"

  local NVM_LOCAL_ALIAS
  NVM_LOCAL_ALIAS="${NVM_LOCAL_PATTERN}"
  local NVM_LOCAL_ALIAS_TEMP

  local NVM_LOCAL_SEEN_ALIASES
  NVM_LOCAL_SEEN_ALIASES="${NVM_LOCAL_ALIAS}"
  while true; do
    NVM_LOCAL_ALIAS_TEMP="$(nvm_alias "${NVM_LOCAL_ALIAS}" 2>/dev/null || nvm_echo)"

    if [ -z "${NVM_LOCAL_ALIAS_TEMP}" ]; then
      break
    fi

    if command printf "${NVM_LOCAL_SEEN_ALIASES}" | nvm_grep -q -e "^${NVM_LOCAL_ALIAS_TEMP}$"; then
      NVM_LOCAL_ALIAS="∞"
      break
    fi

    NVM_LOCAL_SEEN_ALIASES="${NVM_LOCAL_SEEN_ALIASES}\\n${NVM_LOCAL_ALIAS_TEMP}"
    NVM_LOCAL_ALIAS="${NVM_LOCAL_ALIAS_TEMP}"
  done

  if [ -n "${NVM_LOCAL_ALIAS}" ] && [ "_${NVM_LOCAL_ALIAS}" != "_${NVM_LOCAL_PATTERN}" ]; then
    local NVM_LOCAL_IOJS_PREFIX
    NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
    local NVM_LOCAL_NODE_PREFIX
    NVM_LOCAL_NODE_PREFIX="$(nvm_node_prefix)"
    case "${NVM_LOCAL_ALIAS}" in
      '∞' | \
      "${NVM_LOCAL_IOJS_PREFIX}" | "${NVM_LOCAL_IOJS_PREFIX}-" | \
      "${NVM_LOCAL_NODE_PREFIX}")
        nvm_echo "${NVM_LOCAL_ALIAS}"
      ;;
      *)
        nvm_ensure_version_prefix "${NVM_LOCAL_ALIAS}"
      ;;
    esac
    return 0
  fi

  if nvm_validate_implicit_alias "${NVM_LOCAL_PATTERN}" 2>/dev/null; then
    local NVM_LOCAL_IMPLICIT
    NVM_LOCAL_IMPLICIT="$(nvm_print_implicit_alias local "${NVM_LOCAL_PATTERN}" 2>/dev/null)"
    if [ -n "${NVM_LOCAL_IMPLICIT}" ]; then
      nvm_ensure_version_prefix "${NVM_LOCAL_IMPLICIT}"
    fi
  fi

  return 2
}

nvm_resolve_local_alias() {
  if [ -z "${1-}" ]; then
    return 1
  fi

  local NVM_LOCAL_VERSION
  local NVM_LOCAL_EXIT_CODE
  NVM_LOCAL_VERSION="$(nvm_resolve_alias "${1-}")"
  NVM_LOCAL_EXIT_CODE=$?
  if [ -z "${NVM_LOCAL_VERSION}" ]; then
    return ${NVM_LOCAL_EXIT_CODE}
  fi
  if [ "_${NVM_LOCAL_VERSION}" != '_∞' ]; then
    nvm_version "${NVM_LOCAL_VERSION}"
  else
    nvm_echo "${NVM_LOCAL_VERSION}"
  fi
}

nvm_iojs_prefix() {
  nvm_echo 'iojs'
}
nvm_node_prefix() {
  nvm_echo 'node'
}

nvm_is_iojs_version() {
  case "${1-}" in iojs-*) return 0 ;; esac
  return 1
}

nvm_add_iojs_prefix() {
  nvm_echo "$(nvm_iojs_prefix)-$(nvm_ensure_version_prefix "$(nvm_strip_iojs_prefix "${1-}")")"
}

nvm_strip_iojs_prefix() {
  local NVM_LOCAL_IOJS_PREFIX
  NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
  if [ "${1-}" = "${NVM_LOCAL_IOJS_PREFIX}" ]; then
    nvm_echo
  else
    nvm_echo "${1#"${NVM_LOCAL_IOJS_PREFIX}"-}"
  fi
}

nvm_ls() {
  local NVM_LOCAL_PATTERN
  NVM_LOCAL_PATTERN="${1-}"
  local NVM_LOCAL_VERSIONS
  NVM_LOCAL_VERSIONS=''
  if [ "${NVM_LOCAL_PATTERN}" = 'current' ]; then
    nvm_ls_current
    return
  fi

  local NVM_LOCAL_IOJS_PREFIX
  NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_LOCAL_NODE_PREFIX
  NVM_LOCAL_NODE_PREFIX="$(nvm_node_prefix)"
  local NVM_LOCAL_VERSION_DIR_IOJS
  NVM_LOCAL_VERSION_DIR_IOJS="$(nvm_version_dir "${NVM_LOCAL_IOJS_PREFIX}")"
  local NVM_LOCAL_VERSION_DIR_NEW
  NVM_LOCAL_VERSION_DIR_NEW="$(nvm_version_dir new)"
  local NVM_LOCAL_VERSION_DIR_OLD
  NVM_LOCAL_VERSION_DIR_OLD="$(nvm_version_dir old)"

  case "${NVM_LOCAL_PATTERN}" in
    "${NVM_LOCAL_IOJS_PREFIX}" | "${NVM_LOCAL_NODE_PREFIX}")
      NVM_LOCAL_PATTERN="${NVM_LOCAL_PATTERN}-"
    ;;
    *)
      if nvm_resolve_local_alias "${NVM_LOCAL_PATTERN}"; then
        return
      fi
      NVM_LOCAL_PATTERN="$(nvm_ensure_version_prefix "${NVM_LOCAL_PATTERN}")"
    ;;
  esac
  if [ "${NVM_LOCAL_PATTERN}" = 'N/A' ]; then
    return
  fi
  # If it looks like an explicit version, don't do anything funny
  local NVM_LOCAL_PATTERN_STARTS_WITH_V
  case ${NVM_LOCAL_PATTERN} in
    v*) NVM_LOCAL_PATTERN_STARTS_WITH_V=true ;;
    *) NVM_LOCAL_PATTERN_STARTS_WITH_V=false ;;
  esac
  if [ ${NVM_LOCAL_PATTERN_STARTS_WITH_V} = true ] && [ "_$(nvm_num_version_groups "${NVM_LOCAL_PATTERN}")" = "_3" ]; then
    if nvm_is_version_installed "${NVM_LOCAL_PATTERN}"; then
      NVM_LOCAL_VERSIONS="${NVM_LOCAL_PATTERN}"
    elif nvm_is_version_installed "$(nvm_add_iojs_prefix "${NVM_LOCAL_PATTERN}")"; then
      NVM_LOCAL_VERSIONS="$(nvm_add_iojs_prefix "${NVM_LOCAL_PATTERN}")"
    fi
  else
    case "${NVM_LOCAL_PATTERN}" in
      "${NVM_LOCAL_IOJS_PREFIX}-" | "${NVM_LOCAL_NODE_PREFIX}-" | "system") ;;
      *)
        local NVM_LOCAL_NUM_VERSION_GROUPS
        NVM_LOCAL_NUM_VERSION_GROUPS="$(nvm_num_version_groups "${NVM_LOCAL_PATTERN}")"
        if [ "${NVM_LOCAL_NUM_VERSION_GROUPS}" = "2" ] || [ "${NVM_LOCAL_NUM_VERSION_GROUPS}" = "1" ]; then
          NVM_LOCAL_PATTERN="${NVM_LOCAL_PATTERN%.}."
        fi
      ;;
    esac

    nvm_is_zsh && setopt local_options shwordsplit
    nvm_is_zsh && unsetopt local_options markdirs

    local NVM_LOCAL_DIRS_TO_SEARCH1
    NVM_LOCAL_DIRS_TO_SEARCH1=''
    local NVM_LOCAL_DIRS_TO_SEARCH2
    NVM_LOCAL_DIRS_TO_SEARCH2=''
    local NVM_LOCAL_DIRS_TO_SEARCH3
    NVM_LOCAL_DIRS_TO_SEARCH3=''
    local NVM_LOCAL_ADD_SYSTEM
    NVM_LOCAL_ADD_SYSTEM=false
    if nvm_is_iojs_version "${NVM_LOCAL_PATTERN}"; then
      NVM_LOCAL_DIRS_TO_SEARCH1="${NVM_LOCAL_VERSION_DIR_IOJS}"
      NVM_LOCAL_PATTERN="$(nvm_strip_iojs_prefix "${NVM_LOCAL_PATTERN}")"
      if nvm_has_system_iojs; then
        NVM_LOCAL_ADD_SYSTEM=true
      fi
    elif [ "${NVM_LOCAL_PATTERN}" = "${NVM_LOCAL_NODE_PREFIX}-" ]; then
      NVM_LOCAL_DIRS_TO_SEARCH1="${NVM_LOCAL_VERSION_DIR_OLD}"
      NVM_LOCAL_DIRS_TO_SEARCH2="${NVM_LOCAL_VERSION_DIR_NEW}"
      NVM_LOCAL_PATTERN=''
      if nvm_has_system_node; then
        NVM_LOCAL_ADD_SYSTEM=true
      fi
    else
      NVM_LOCAL_DIRS_TO_SEARCH1="${NVM_LOCAL_VERSION_DIR_OLD}"
      NVM_LOCAL_DIRS_TO_SEARCH2="${NVM_LOCAL_VERSION_DIR_NEW}"
      NVM_LOCAL_DIRS_TO_SEARCH3="${NVM_LOCAL_VERSION_DIR_IOJS}"
      if nvm_has_system_iojs || nvm_has_system_node; then
        NVM_LOCAL_ADD_SYSTEM=true
      fi
    fi

    if ! [ -d "${NVM_LOCAL_DIRS_TO_SEARCH1}" ] || ! (command ls -1qA "${NVM_LOCAL_DIRS_TO_SEARCH1}" | nvm_grep -q .); then
      NVM_LOCAL_DIRS_TO_SEARCH1=''
    fi
    if ! [ -d "${NVM_LOCAL_DIRS_TO_SEARCH2}" ] || ! (command ls -1qA "${NVM_LOCAL_DIRS_TO_SEARCH2}" | nvm_grep -q .); then
      NVM_LOCAL_DIRS_TO_SEARCH2="${NVM_LOCAL_DIRS_TO_SEARCH1}"
    fi
    if ! [ -d "${NVM_LOCAL_DIRS_TO_SEARCH3}" ] || ! (command ls -1qA "${NVM_LOCAL_DIRS_TO_SEARCH3}" | nvm_grep -q .); then
      NVM_LOCAL_DIRS_TO_SEARCH3="${NVM_LOCAL_DIRS_TO_SEARCH2}"
    fi

    local NVM_LOCAL_SEARCH_PATTERN
    if [ -z "${NVM_LOCAL_PATTERN}" ]; then
      NVM_LOCAL_PATTERN='v'
      NVM_LOCAL_SEARCH_PATTERN='.*'
    else
      NVM_LOCAL_SEARCH_PATTERN="$(nvm_echo "${NVM_LOCAL_PATTERN}" | command sed 's#\.#\\\.#g;')"
    fi
    if [ -n "${NVM_LOCAL_DIRS_TO_SEARCH1}${NVM_LOCAL_DIRS_TO_SEARCH2}${NVM_LOCAL_DIRS_TO_SEARCH3}" ]; then
      NVM_LOCAL_VERSIONS="$(command find "${NVM_LOCAL_DIRS_TO_SEARCH1}"/* "${NVM_LOCAL_DIRS_TO_SEARCH2}"/* "${NVM_LOCAL_DIRS_TO_SEARCH3}"/* -name . -o -type d -prune -o -path "${NVM_LOCAL_PATTERN}*" \
        | command sed -e "
            s#${NVM_LOCAL_VERSION_DIR_IOJS}/#versions/${NVM_LOCAL_IOJS_PREFIX}/#;
            s#^${NVM_DIR}/##;
            \\#^[^v]# d;
            \\#^versions\$# d;
            s#^versions/##;
            s#^v#${NVM_LOCAL_NODE_PREFIX}/v#;
            \\#${NVM_LOCAL_SEARCH_PATTERN}# !d;
          " \
          -e 's#^\([^/]\{1,\}\)/\(.*\)$#\2.\1#;' \
        | command sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n \
        | command sed -e 's#\(.*\)\.\([^\.]\{1,\}\)$#\2-\1#;' \
                      -e "s#^${NVM_LOCAL_NODE_PREFIX}-##;" \
      )"
    fi
  fi

  if [ "${NVM_LOCAL_ADD_SYSTEM-}" = true ]; then
    if [ -z "${NVM_LOCAL_PATTERN}" ] || [ "${NVM_LOCAL_PATTERN}" = 'v' ]; then
      NVM_LOCAL_VERSIONS="${NVM_LOCAL_VERSIONS}$(command printf '\n%s' 'system')"
    elif [ "${NVM_LOCAL_PATTERN}" = 'system' ]; then
      NVM_LOCAL_VERSIONS="$(command printf '%s' 'system')"
    fi
  fi

  if [ -z "${NVM_LOCAL_VERSIONS}" ]; then
    nvm_echo 'N/A'
    return 3
  fi

  nvm_echo "${NVM_LOCAL_VERSIONS}"
}

nvm_ls_remote() {
  local NVM_LOCAL_PATTERN
  NVM_LOCAL_PATTERN="${1-}"
  if nvm_validate_implicit_alias "${NVM_LOCAL_PATTERN}" 2>/dev/null ; then
    local NVM_LOCAL_IMPLICIT
    NVM_LOCAL_IMPLICIT="$(nvm_print_implicit_alias remote "${NVM_LOCAL_PATTERN}")"
    if [ -z "${NVM_LOCAL_IMPLICIT-}" ] || [ "${NVM_LOCAL_IMPLICIT}" = 'N/A' ]; then
      nvm_echo "N/A"
      return 3
    fi
    NVM_LOCAL_PATTERN="$(NVM_LTS="${NVM_LTS-}" nvm_ls_remote "${NVM_LOCAL_IMPLICIT}" | command tail -1 | command awk '{ print $1 }')"
  elif [ -n "${NVM_LOCAL_PATTERN}" ]; then
    NVM_LOCAL_PATTERN="$(nvm_ensure_version_prefix "${NVM_LOCAL_PATTERN}")"
  else
    NVM_LOCAL_PATTERN=".*"
  fi
  NVM_LTS="${NVM_LTS-}" nvm_ls_remote_index_tab node std "${NVM_LOCAL_PATTERN}"
}

nvm_ls_remote_iojs() {
  NVM_LTS="${NVM_LTS-}" nvm_ls_remote_index_tab iojs std "${1-}"
}

# args flavor, type, version
nvm_ls_remote_index_tab() {
  local NVM_LOCAL_LTS
  NVM_LOCAL_LTS="${NVM_LTS-}"
  if [ "$#" -lt 3 ]; then
    nvm_err 'not enough arguments'
    return 5
  fi

  local NVM_LOCAL_FLAVOR
  NVM_LOCAL_FLAVOR="${1-}"

  local NVM_LOCAL_TYPE
  NVM_LOCAL_TYPE="${2-}"

  local NVM_LOCAL_MIRROR
  NVM_LOCAL_MIRROR="$(nvm_get_mirror "${NVM_LOCAL_FLAVOR}" "${NVM_LOCAL_TYPE}")"
  if [ -z "${NVM_LOCAL_MIRROR}" ]; then
    return 3
  fi

  local NVM_LOCAL_PREFIX
  NVM_LOCAL_PREFIX=''
  case "${NVM_LOCAL_FLAVOR}-${NVM_LOCAL_TYPE}" in
    iojs-std) NVM_LOCAL_PREFIX="$(nvm_iojs_prefix)-" ;;
    node-std) NVM_LOCAL_PREFIX='' ;;
    iojs-*)
      nvm_err 'unknown type of io.js release'
      return 4
    ;;
    *)
      nvm_err 'unknown type of node.js release'
      return 4
    ;;
  esac
  local NVM_LOCAL_SORT_COMMAND
  NVM_LOCAL_SORT_COMMAND='command sort'
  case "${NVM_LOCAL_FLAVOR}" in
    node) NVM_LOCAL_SORT_COMMAND='command sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n' ;;
  esac

  local NVM_LOCAL_PATTERN
  NVM_LOCAL_PATTERN="${3-}"

  if [ "${NVM_LOCAL_PATTERN#"${NVM_LOCAL_PATTERN%?}"}" = '.' ]; then
    NVM_LOCAL_PATTERN="${NVM_LOCAL_PATTERN%.}"
  fi

  local NVM_LOCAL_VERSIONS
  if [ -n "${NVM_LOCAL_PATTERN}" ] && [ "${NVM_LOCAL_PATTERN}" != '*' ]; then
    if [ "${NVM_LOCAL_FLAVOR}" = 'iojs' ]; then
      NVM_LOCAL_PATTERN="$(nvm_ensure_version_prefix "$(nvm_strip_iojs_prefix "${NVM_LOCAL_PATTERN}")")"
    else
      NVM_LOCAL_PATTERN="$(nvm_ensure_version_prefix "${NVM_LOCAL_PATTERN}")"
    fi
  else
    unset NVM_LOCAL_PATTERN
  fi

  nvm_is_zsh && setopt local_options shwordsplit
  local NVM_LOCAL_VERSION_LIST
  NVM_LOCAL_VERSION_LIST="$(nvm_download -L -s "${NVM_LOCAL_MIRROR}/index.tab" -o - \
    | command sed "
        1d;
        s/^/${NVM_LOCAL_PREFIX}/;
      " \
  )"
  local NVM_LOCAL_LTS_ALIAS
  local NVM_LOCAL_LTS_VERSION
  command mkdir -p "$(nvm_alias_path)/lts"
  { command awk '{
        if ($10 ~ /^\-?$/) { next }
        if ($10 && !a[tolower($10)]++) {
          if (alias) { print alias, version }
          alias_name = "lts/" tolower($10)
          if (!alias) { print "lts/*", alias_name }
          alias = alias_name
          version = $1
        }
      }
      END {
        if (alias) {
          print alias, version
        }
      }' \
    | while read -r NVM_LOCAL_LTS_ALIAS_LINE; do
      NVM_LOCAL_LTS_ALIAS="${NVM_LOCAL_LTS_ALIAS_LINE%% *}"
      NVM_LOCAL_LTS_VERSION="${NVM_LOCAL_LTS_ALIAS_LINE#* }"
      nvm_make_alias "${NVM_LOCAL_LTS_ALIAS}" "${NVM_LOCAL_LTS_VERSION}" >/dev/null 2>&1
    done; } << EOF
${NVM_LOCAL_VERSION_LIST}
EOF

  if [ -n "${NVM_LOCAL_LTS-}" ]; then
    NVM_LOCAL_LTS="$(nvm_normalize_lts "lts/${NVM_LOCAL_LTS}")"
    NVM_LOCAL_LTS="${NVM_LOCAL_LTS#lts/}"
  fi

  NVM_LOCAL_VERSIONS="$({ command awk -v lts="${NVM_LOCAL_LTS-}" '{
        if (!$1) { next }
        if (lts && $10 ~ /^\-?$/) { next }
        if (lts && lts != "*" && tolower($10) !~ tolower(lts)) { next }
        if ($10 !~ /^\-?$/) {
          if ($10 && $10 != prev) {
            print $1, $10, "*"
          } else {
            print $1, $10
          }
        } else {
          print $1
        }
        prev=$10;
      }' \
    | nvm_grep -w "${NVM_LOCAL_PATTERN:-.*}" \
    | ${NVM_LOCAL_SORT_COMMAND}; } << EOF
${NVM_LOCAL_VERSION_LIST}
EOF
)"
  if [ -z "${NVM_LOCAL_VERSIONS}" ]; then
    nvm_echo 'N/A'
    return 3
  fi
  nvm_echo "${NVM_LOCAL_VERSIONS}"
}

nvm_get_checksum_binary() {
  if nvm_has_non_aliased 'sha256sum'; then
    nvm_echo 'sha256sum'
  elif nvm_has_non_aliased 'shasum'; then
    nvm_echo 'shasum'
  elif nvm_has_non_aliased 'sha256'; then
    nvm_echo 'sha256'
  elif nvm_has_non_aliased 'gsha256sum'; then
    nvm_echo 'gsha256sum'
  elif nvm_has_non_aliased 'openssl'; then
    nvm_echo 'openssl'
  elif nvm_has_non_aliased 'bssl'; then
    nvm_echo 'bssl'
  elif nvm_has_non_aliased 'sha1sum'; then
    nvm_echo 'sha1sum'
  elif nvm_has_non_aliased 'sha1'; then
    nvm_echo 'sha1'
  else
    nvm_err 'Unaliased sha256sum, shasum, sha256, gsha256sum, openssl, or bssl not found.'
    nvm_err 'Unaliased sha1sum or sha1 not found.'
    return 1
  fi
}

nvm_get_checksum_alg() {
  local NVM_LOCAL_CHECKSUM_BIN
  NVM_LOCAL_CHECKSUM_BIN="$(nvm_get_checksum_binary 2>/dev/null)"
  case "${NVM_LOCAL_CHECKSUM_BIN-}" in
    sha256sum | shasum | sha256 | gsha256sum | openssl | bssl)
      nvm_echo 'sha-256'
    ;;
    sha1sum | sha1)
      nvm_echo 'sha-1'
    ;;
    *)
      nvm_get_checksum_binary
      return $?
    ;;
  esac
}

nvm_compute_checksum() {
  local NVM_LOCAL_FILE
  NVM_LOCAL_FILE="${1-}"
  if [ -z "${NVM_LOCAL_FILE}" ]; then
    nvm_err 'Provided file to checksum is empty.'
    return 2
  elif ! [ -f "${NVM_LOCAL_FILE}" ]; then
    nvm_err 'Provided file to checksum does not exist.'
    return 1
  fi

  if nvm_has_non_aliased "sha256sum"; then
    nvm_err 'Computing checksum with sha256sum'
    command sha256sum "${NVM_LOCAL_FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "shasum"; then
    nvm_err 'Computing checksum with shasum -a 256'
    command shasum -a 256 "${NVM_LOCAL_FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "sha256"; then
    nvm_err 'Computing checksum with sha256 -q'
    command sha256 -q "${NVM_LOCAL_FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "gsha256sum"; then
    nvm_err 'Computing checksum with gsha256sum'
    command gsha256sum "${NVM_LOCAL_FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "openssl"; then
    nvm_err 'Computing checksum with openssl dgst -sha256'
    command openssl dgst -sha256 "${NVM_LOCAL_FILE}" | command awk '{print $NF}'
  elif nvm_has_non_aliased "bssl"; then
    nvm_err 'Computing checksum with bssl sha256sum'
    command bssl sha256sum "${NVM_LOCAL_FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "sha1sum"; then
    nvm_err 'Computing checksum with sha1sum'
    command sha1sum "${NVM_LOCAL_FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "sha1"; then
    nvm_err 'Computing checksum with sha1 -q'
    command sha1 -q "${NVM_LOCAL_FILE}"
  fi
}

nvm_compare_checksum() {
  local NVM_LOCAL_FILE
  NVM_LOCAL_FILE="${1-}"
  if [ -z "${NVM_LOCAL_FILE}" ]; then
    nvm_err 'Provided file to checksum is empty.'
    return 4
  elif ! [ -f "${NVM_LOCAL_FILE}" ]; then
    nvm_err 'Provided file to checksum does not exist.'
    return 3
  fi

  local NVM_LOCAL_COMPUTED_SUM
  NVM_LOCAL_COMPUTED_SUM="$(nvm_compute_checksum "${NVM_LOCAL_FILE}")"

  local NVM_LOCAL_CHECKSUM
  NVM_LOCAL_CHECKSUM="${2-}"
  if [ -z "${NVM_LOCAL_CHECKSUM}" ]; then
    nvm_err 'Provided checksum to compare to is empty.'
    return 2
  fi

  if [ -z "${NVM_LOCAL_COMPUTED_SUM}" ]; then
    nvm_err "Computed checksum of '${NVM_LOCAL_FILE}' is empty." # missing in raspberry pi binary
    nvm_err 'WARNING: Continuing *without checksum verification*'
    return
  elif [ "${NVM_LOCAL_COMPUTED_SUM}" != "${NVM_LOCAL_CHECKSUM}" ]; then
    nvm_err "Checksums do not match: '${NVM_LOCAL_COMPUTED_SUM}' found, '${NVM_LOCAL_CHECKSUM}' expected."
    return 1
  fi
  nvm_err 'Checksums matched!'
}

# args: flavor, type, version, slug, compression
nvm_get_checksum() {
  local NVM_LOCAL_FLAVOR
  case "${1-}" in
    node | iojs) NVM_LOCAL_FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 2
    ;;
  esac

  local NVM_LOCAL_MIRROR
  NVM_LOCAL_MIRROR="$(nvm_get_mirror "${NVM_LOCAL_FLAVOR}" "${2-}")"
  if [ -z "${NVM_LOCAL_MIRROR}" ]; then
    return 1
  fi

  local NVM_LOCAL_SHASUMS_URL
  if [ "$(nvm_get_checksum_alg)" = 'sha-256' ]; then
    NVM_LOCAL_SHASUMS_URL="${NVM_LOCAL_MIRROR}/${3}/SHASUMS256.txt"
  else
    NVM_LOCAL_SHASUMS_URL="${NVM_LOCAL_MIRROR}/${3}/SHASUMS.txt"
  fi

  nvm_download -L -s "${NVM_LOCAL_SHASUMS_URL}" -o - | command awk "{ if (\"${4}.${5}\" == \$2) print \$1}"
}

nvm_print_versions() {
  local NVM_LOCAL_VERSION
  local NVM_LOCAL_LTS
  local NVM_LOCAL_FORMAT
  local NVM_LOCAL_CURRENT
  local NVM_LOCAL_LATEST_LTS_COLOR
  local NVM_LOCAL_OLD_LTS_COLOR

  local NVM_LOCAL_INSTALLED_COLOR
  local NVM_LOCAL_SYSTEM_COLOR
  local NVM_LOCAL_CURRENT_COLOR
  local NVM_LOCAL_NOT_INSTALLED_COLOR
  local NVM_LOCAL_DEFAULT_COLOR
  local NVM_LOCAL_LTS_COLOR

  NVM_LOCAL_INSTALLED_COLOR=$(nvm_get_colors 1)
  NVM_LOCAL_SYSTEM_COLOR=$(nvm_get_colors 2)
  NVM_LOCAL_CURRENT_COLOR=$(nvm_get_colors 3)
  NVM_LOCAL_NOT_INSTALLED_COLOR=$(nvm_get_colors 4)
  NVM_LOCAL_DEFAULT_COLOR=$(nvm_get_colors 5)
  NVM_LOCAL_LTS_COLOR=$(nvm_get_colors 6)

  NVM_LOCAL_CURRENT=$(nvm_ls_current)
  NVM_LOCAL_LATEST_LTS_COLOR=$(nvm_echo "${NVM_LOCAL_CURRENT_COLOR}" | command tr '0;' '1;')
  NVM_LOCAL_OLD_LTS_COLOR="${NVM_LOCAL_DEFAULT_COLOR}"
  local NVM_LOCAL_HAS_COLORS
  if [ -z "${NVM_NO_COLORS-}" ] && nvm_has_colors; then
    NVM_LOCAL_HAS_COLORS=1
  fi
  local NVM_LOCAL_LTS_LENGTH
  local NVM_LOCAL_LTS_FORMAT
  nvm_echo "${1-}" \
  | command sed '1!G;h;$!d' \
  | command awk '{ if ($2 && $3 && $3 == "*") { print $1, "(Latest LTS: " $2 ")" } else if ($2) { print $1, "(LTS: " $2 ")" } else { print $1 } }' \
  | command sed '1!G;h;$!d' \
  | while read -r NVM_LOCAL_VERSION_LINE; do
    NVM_LOCAL_VERSION="${NVM_LOCAL_VERSION_LINE%% *}"
    NVM_LOCAL_LTS="${NVM_LOCAL_VERSION_LINE#* }"
    NVM_LOCAL_FORMAT='%15s'
    if [ "_${NVM_LOCAL_VERSION}" = "_${NVM_LOCAL_CURRENT}" ]; then
      if [ "${NVM_LOCAL_HAS_COLORS-}" = '1' ]; then
        NVM_LOCAL_FORMAT="\033[${NVM_LOCAL_CURRENT_COLOR}-> %12s\033[0m"
      else
        NVM_LOCAL_FORMAT='-> %12s *'
      fi
    elif [ "${NVM_LOCAL_VERSION}" = "system" ]; then
      if [ "${NVM_LOCAL_HAS_COLORS-}" = '1' ]; then
        NVM_LOCAL_FORMAT="\033[${NVM_LOCAL_SYSTEM_COLOR}%15s\033[0m"
      else
        NVM_LOCAL_FORMAT='%15s *'
      fi
    elif nvm_is_version_installed "${NVM_LOCAL_VERSION}"; then
      if [ "${NVM_LOCAL_HAS_COLORS-}" = '1' ]; then
        NVM_LOCAL_FORMAT="\033[${NVM_LOCAL_INSTALLED_COLOR}%15s\033[0m"
      else
        NVM_LOCAL_FORMAT='%15s *'
      fi
    fi
    if [ "${NVM_LOCAL_LTS}" != "${NVM_LOCAL_VERSION}" ]; then
      case "${NVM_LOCAL_LTS}" in
        *Latest*)
          NVM_LOCAL_LTS="${NVM_LOCAL_LTS##Latest }"
          NVM_LOCAL_LTS_LENGTH="${#NVM_LOCAL_LTS}"
          if [ "${NVM_LOCAL_HAS_COLORS-}" = '1' ]; then
            NVM_LOCAL_LTS_FORMAT="  \\033[${NVM_LOCAL_LATEST_LTS_COLOR}%${NVM_LOCAL_LTS_LENGTH}s\\033[0m"
          else
            NVM_LOCAL_LTS_FORMAT="  %${NVM_LOCAL_LTS_LENGTH}s"
          fi
        ;;
        *)
          NVM_LOCAL_LTS_LENGTH="${#NVM_LOCAL_LTS}"
          if [ "${NVM_LOCAL_HAS_COLORS-}" = '1' ]; then
            NVM_LOCAL_LTS_FORMAT="  \\033[${NVM_LOCAL_OLD_LTS_COLOR}%${NVM_LOCAL_LTS_LENGTH}s\\033[0m"
          else
            NVM_LOCAL_LTS_FORMAT="  %${NVM_LOCAL_LTS_LENGTH}s"
          fi
        ;;
      esac
      command printf -- "${NVM_LOCAL_FORMAT}${NVM_LOCAL_LTS_FORMAT}\\n" "${NVM_LOCAL_VERSION}" " ${NVM_LOCAL_LTS}"
    else
      command printf -- "${NVM_LOCAL_FORMAT}\\n" "${NVM_LOCAL_VERSION}"
    fi
  done
}

nvm_validate_implicit_alias() {
  local NVM_LOCAL_IOJS_PREFIX
  NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_LOCAL_NODE_PREFIX
  NVM_LOCAL_NODE_PREFIX="$(nvm_node_prefix)"

  case "$1" in
    "stable" | "unstable" | "${NVM_LOCAL_IOJS_PREFIX}" | "${NVM_LOCAL_NODE_PREFIX}")
      return
    ;;
    *)
      nvm_err "Only implicit aliases 'stable', 'unstable', '${NVM_LOCAL_IOJS_PREFIX}', and '${NVM_LOCAL_NODE_PREFIX}' are supported."
      return 1
    ;;
  esac
}

nvm_print_implicit_alias() {
  if [ "_$1" != "_local" ] && [ "_$1" != "_remote" ]; then
    nvm_err "nvm_print_implicit_alias must be specified with local or remote as the first argument."
    return 1
  fi

  local NVM_LOCAL_IMPLICIT
  NVM_LOCAL_IMPLICIT="$2"
  if ! nvm_validate_implicit_alias "${NVM_LOCAL_IMPLICIT}"; then
    return 2
  fi

  local NVM_LOCAL_IOJS_PREFIX
  NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_LOCAL_NODE_PREFIX
  NVM_LOCAL_NODE_PREFIX="$(nvm_node_prefix)"
  local NVM_LOCAL_COMMAND
  local NVM_LOCAL_ADD_PREFIX_COMMAND
  local NVM_LOCAL_LAST_TWO
  case "${NVM_LOCAL_IMPLICIT}" in
    "${NVM_LOCAL_IOJS_PREFIX}")
      NVM_LOCAL_COMMAND="nvm_ls_remote_iojs"
      NVM_LOCAL_ADD_PREFIX_COMMAND="nvm_add_iojs_prefix"
      if [ "_$1" = "_local" ]; then
        NVM_LOCAL_COMMAND="nvm_ls ${NVM_LOCAL_IMPLICIT}"
      fi

      nvm_is_zsh && setopt local_options shwordsplit

      local NVM_LOCAL_IOJS_VERSION
      local NVM_LOCAL_EXIT_CODE
      NVM_LOCAL_IOJS_VERSION="$(${NVM_LOCAL_COMMAND})" &&:
      NVM_LOCAL_EXIT_CODE="$?"
      if [ "_${NVM_LOCAL_EXIT_CODE}" = "_0" ]; then
        NVM_LOCAL_IOJS_VERSION="$(nvm_echo "${NVM_LOCAL_IOJS_VERSION}" | command sed "s/^${NVM_LOCAL_IMPLICIT}-//" | nvm_grep -e '^v' | command cut -c2- | command cut -d . -f 1,2 | uniq | command tail -1)"
      fi

      if [ "_${NVM_LOCAL_IOJS_VERSION}" = "_N/A" ]; then
        nvm_echo 'N/A'
      else
        ${NVM_LOCAL_ADD_PREFIX_COMMAND} "${NVM_LOCAL_IOJS_VERSION}"
      fi
      return ${NVM_LOCAL_EXIT_CODE}
    ;;
    "${NVM_LOCAL_NODE_PREFIX}")
      nvm_echo 'stable'
      return
    ;;
    *)
      NVM_LOCAL_COMMAND="nvm_ls_remote"
      if [ "_$1" = "_local" ]; then
        NVM_LOCAL_COMMAND="nvm_ls node"
      fi

      nvm_is_zsh && setopt local_options shwordsplit

      NVM_LOCAL_LAST_TWO=$(${NVM_LOCAL_COMMAND} | nvm_grep -e '^v' | command cut -c2- | command cut -d . -f 1,2 | uniq)
    ;;
  esac
  local NVM_LOCAL_MINOR
  local NVM_LOCAL_STABLE
  local NVM_LOCAL_UNSTABLE
  local NVM_LOCAL_MOD
  local NVM_LOCAL_NORMALIZED_VERSION

  nvm_is_zsh && setopt local_options shwordsplit
  for NVM_LOCAL_MINOR in ${NVM_LOCAL_LAST_TWO}; do
    NVM_LOCAL_NORMALIZED_VERSION="$(nvm_normalize_version "${NVM_LOCAL_MINOR}")"
    if [ "_0${NVM_LOCAL_NORMALIZED_VERSION#?}" != "_${NVM_LOCAL_NORMALIZED_VERSION}" ]; then
      NVM_LOCAL_STABLE="${NVM_LOCAL_MINOR}"
    else
      NVM_LOCAL_MOD="$(awk 'BEGIN { print int(ARGV[1] / 1000000) % 2 ; exit(0) }' "${NVM_LOCAL_NORMALIZED_VERSION}")"
      if [ "${NVM_LOCAL_MOD}" -eq 0 ]; then
        NVM_LOCAL_STABLE="${NVM_LOCAL_MINOR}"
      elif [ "${NVM_LOCAL_MOD}" -eq 1 ]; then
        NVM_LOCAL_UNSTABLE="${NVM_LOCAL_MINOR}"
      fi
    fi
  done

  if [ "_$2" = '_stable' ]; then
    nvm_echo "${NVM_LOCAL_STABLE}"
  elif [ "_$2" = '_unstable' ]; then
    nvm_echo "${NVM_LOCAL_UNSTABLE:-"N/A"}"
  fi
}

nvm_get_os() {
  local NVM_LOCAL_UNAME
  NVM_LOCAL_UNAME="$(command uname -a)"
  local NVM_LOCAL_OS
  case "${NVM_LOCAL_UNAME}" in
    Linux\ *) NVM_LOCAL_OS=linux ;;
    Darwin\ *) NVM_LOCAL_OS=darwin ;;
    SunOS\ *) NVM_LOCAL_OS=sunos ;;
    FreeBSD\ *) NVM_LOCAL_OS=freebsd ;;
    OpenBSD\ *) NVM_LOCAL_OS=openbsd ;;
    AIX\ *) NVM_LOCAL_OS=aix ;;
    CYGWIN* | MSYS* | MINGW*) NVM_LOCAL_OS=win ;;
  esac
  nvm_echo "${NVM_LOCAL_OS-}"
}

nvm_get_arch() {
  local NVM_LOCAL_HOST_ARCH
  local NVM_LOCAL_OS

  NVM_LOCAL_OS="$(nvm_get_os)"
  # If the OS is SunOS, first try to use pkgsrc to guess
  # the most appropriate arch. If it's not available, use
  # isainfo to get the instruction set supported by the
  # kernel.
  if [ "_${NVM_LOCAL_OS}" = "_sunos" ]; then
    if NVM_LOCAL_HOST_ARCH=$(pkg_info -Q MACHINE_ARCH pkg_install); then
      NVM_LOCAL_HOST_ARCH=$(nvm_echo "${NVM_LOCAL_HOST_ARCH}" | command tail -1)
    else
      NVM_LOCAL_HOST_ARCH=$(isainfo -n)
    fi
  elif [ "_${NVM_LOCAL_OS}" = "_aix" ]; then
    NVM_LOCAL_HOST_ARCH=ppc64
  else
    NVM_LOCAL_HOST_ARCH="$(command uname -m)"
  fi

  local NVM_LOCAL_ARCH
  case "${NVM_LOCAL_HOST_ARCH}" in
    x86_64 | amd64) NVM_LOCAL_ARCH="x64" ;;
    i*86) NVM_LOCAL_ARCH="x86" ;;
    aarch64) NVM_LOCAL_ARCH="arm64" ;;
    *) NVM_LOCAL_ARCH="${NVM_LOCAL_HOST_ARCH}" ;;
  esac

  # If running a 64bit ARM kernel but a 32bit ARM userland,
  # change ARCH to 32bit ARM (armv7l) if /sbin/init is 32bit executable
  local NVM_LOCAL_L
  if [ "$(uname)" = "Linux" ] && [ "${NVM_LOCAL_ARCH}" = arm64 ] &&
    NVM_LOCAL_L="$(ls -dl /sbin/init 2>/dev/null)" &&
    [ "$(od -An -t x1 -j 4 -N 1 "${NVM_LOCAL_L#*-> }")" = ' 01' ]; then
    NVM_LOCAL_ARCH=armv7l
    NVM_LOCAL_HOST_ARCH=armv7l
  fi

  nvm_echo "${NVM_LOCAL_ARCH}"
}

nvm_get_minor_version() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="$1"

  if [ -z "${NVM_LOCAL_VERSION}" ]; then
    nvm_err 'a version is required'
    return 1
  fi

  case "${NVM_LOCAL_VERSION}" in
    v | .* | *..* | v*[!.0123456789]* | [!v]*[!.0123456789]* | [!v0123456789]* | v[!0123456789]*)
      nvm_err 'invalid version number'
      return 2
    ;;
  esac

  local NVM_LOCAL_PREFIXED_VERSION
  NVM_LOCAL_PREFIXED_VERSION="$(nvm_format_version "${NVM_LOCAL_VERSION}")"

  local NVM_LOCAL_MINOR
  NVM_LOCAL_MINOR="$(nvm_echo "${NVM_LOCAL_PREFIXED_VERSION}" | nvm_grep -e '^v' | command cut -c2- | command cut -d . -f 1,2)"
  if [ -z "${NVM_LOCAL_MINOR}" ]; then
    nvm_err 'invalid version number! (please report this)'
    return 3
  fi
  nvm_echo "${NVM_LOCAL_MINOR}"
}

nvm_ensure_default_set() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="$1"
  if [ -z "${NVM_LOCAL_VERSION}" ]; then
    nvm_err 'nvm_ensure_default_set: a version is required'
    return 1
  elif nvm_alias default >/dev/null 2>&1; then
    # default already set
    return 0
  fi
  local NVM_LOCAL_OUTPUT
  NVM_LOCAL_OUTPUT="$(nvm alias default "${NVM_LOCAL_VERSION}")"
  local NVM_LOCAL_EXIT_CODE
  NVM_LOCAL_EXIT_CODE="$?"
  nvm_echo "Creating default alias: ${NVM_LOCAL_OUTPUT}"
  return ${NVM_LOCAL_EXIT_CODE}
}

nvm_is_merged_node_version() {
  nvm_version_greater_than_or_equal_to "$1" v4.0.0
}

nvm_get_mirror() {
  case "${1}-${2}" in
    node-std) nvm_echo "${NVM_NODEJS_ORG_MIRROR:-https://nodejs.org/dist}" ;;
    iojs-std) nvm_echo "${NVM_IOJS_ORG_MIRROR:-https://iojs.org/dist}" ;;
    *)
      nvm_err 'unknown type of node.js or io.js release'
      return 1
    ;;
  esac
}

# args: os, prefixed version, version, tarball, extract directory
nvm_install_binary_extract() {
  if [ "$#" -ne 5 ]; then
    nvm_err 'nvm_install_binary_extract needs 5 parameters'
    return 1
  fi

  local NVM_LOCAL_OS
  local NVM_LOCAL_PREFIXED_VERSION
  local NVM_LOCAL_VERSION
  local NVM_LOCAL_TARBALL
  local NVM_LOCAL_TMPDIR
  NVM_LOCAL_OS="${1}"
  NVM_LOCAL_PREFIXED_VERSION="${2}"
  NVM_LOCAL_VERSION="${3}"
  NVM_LOCAL_TARBALL="${4}"
  NVM_LOCAL_TMPDIR="${5}"

  local NVM_LOCAL_VERSION_PATH

  [ -n "${NVM_LOCAL_TMPDIR-}" ] && \
  command mkdir -p "${NVM_LOCAL_TMPDIR}" && \
  NVM_LOCAL_VERSION_PATH="$(nvm_version_path "${NVM_LOCAL_PREFIXED_VERSION}")" || return 1

  # For Windows system (GitBash with MSYS, Cygwin)
  if [ "${NVM_LOCAL_OS}" = 'win' ]; then
    NVM_LOCAL_VERSION_PATH="${NVM_LOCAL_VERSION_PATH}/bin"
    command unzip -q "${NVM_LOCAL_TARBALL}" -d "${NVM_LOCAL_TMPDIR}" || return 1
  # For non Windows system (including WSL running on Windows)
  else
    nvm_extract_tarball "${NVM_LOCAL_OS}" "${NVM_LOCAL_VERSION}" "${NVM_LOCAL_TARBALL}" "${NVM_LOCAL_TMPDIR}"
  fi

  command mkdir -p "${NVM_LOCAL_VERSION_PATH}" || return 1

  if [ "${NVM_LOCAL_OS}" = 'win' ]; then
    command mv "${NVM_LOCAL_TMPDIR}/"*/* "${NVM_LOCAL_VERSION_PATH}" || return 1
    command chmod +x "${NVM_LOCAL_VERSION_PATH}"/node.exe || return 1
    command chmod +x "${NVM_LOCAL_VERSION_PATH}"/npm || return 1
    command chmod +x "${NVM_LOCAL_VERSION_PATH}"/npx 2>/dev/null
  else
    command mv "${NVM_LOCAL_TMPDIR}/"* "${NVM_LOCAL_VERSION_PATH}" || return 1
  fi

  command rm -rf "${NVM_LOCAL_TMPDIR}"

  return 0
}

# args: flavor, type, version, reinstall
nvm_install_binary() {
  local NVM_LOCAL_FLAVOR
  case "${1-}" in
    node | iojs) NVM_LOCAL_FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 4
    ;;
  esac

  local NVM_LOCAL_TYPE
  NVM_LOCAL_TYPE="${2-}"

  local NVM_LOCAL_PREFIXED_VERSION
  NVM_LOCAL_PREFIXED_VERSION="${3-}"
  if [ -z "${NVM_LOCAL_PREFIXED_VERSION}" ]; then
    nvm_err 'A version number is required.'
    return 3
  fi

  local NVM_LOCAL_NOSOURCE
  NVM_LOCAL_NOSOURCE="${4-}"

  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="$(nvm_strip_iojs_prefix "${NVM_LOCAL_PREFIXED_VERSION}")"

  local NVM_LOCAL_OS
  NVM_LOCAL_OS="$(nvm_get_os)"

  if [ -z "${NVM_LOCAL_OS}" ]; then
    return 2
  fi

  local NVM_LOCAL_TARBALL
  local NVM_LOCAL_TMPDIR

  local NVM_LOCAL_PROGRESS_BAR
  local NVM_LOCAL_NODE_OR_IOJS
  if [ "${NVM_LOCAL_FLAVOR}" = 'node' ]; then
    NVM_LOCAL_NODE_OR_IOJS="${NVM_LOCAL_FLAVOR}"
  elif [ "${NVM_LOCAL_FLAVOR}" = 'iojs' ]; then
    NVM_LOCAL_NODE_OR_IOJS="io.js"
  fi
  if [ "${NVM_NO_PROGRESS-}" = "1" ]; then
    # --silent, --show-error, use short option as @samrocketman mentions the compatibility issue.
    NVM_LOCAL_PROGRESS_BAR="-sS"
  else
    NVM_LOCAL_PROGRESS_BAR="--progress-bar"
  fi
  nvm_echo "Downloading and installing ${NVM_LOCAL_NODE_OR_IOJS-} ${NVM_LOCAL_VERSION}..."
  NVM_LOCAL_TARBALL="$(NVM_LOCAL_PROGRESS_BAR="${NVM_LOCAL_PROGRESS_BAR}" nvm_download_artifact "${NVM_LOCAL_FLAVOR}" binary "${NVM_LOCAL_TYPE-}" "${NVM_LOCAL_VERSION}" | command tail -1)"
  if [ -f "${NVM_LOCAL_TARBALL}" ]; then
    NVM_LOCAL_TMPDIR="$(dirname "${NVM_LOCAL_TARBALL}")/files"
  fi

  if nvm_install_binary_extract "${NVM_LOCAL_OS}" "${NVM_LOCAL_PREFIXED_VERSION}" "${NVM_LOCAL_VERSION}" "${NVM_LOCAL_TARBALL}" "${NVM_LOCAL_TMPDIR}"; then
    if [ -n "${NVM_LOCAL_ALIAS-}" ]; then
      nvm alias "${NVM_LOCAL_ALIAS}" "${NVM_LOCAL_PROVIDED_VERSION}"
    fi
    return 0
  fi


  # Read NVM_LOCAL_NOSOURCE from arguments
  if [ "${NVM_LOCAL_NOSOURCE-}" = '1' ]; then
      nvm_err 'Binary download failed. Download from source aborted.'
      return 0
  fi

  nvm_err 'Binary download failed, trying source.'
  if [ -n "${NVM_LOCAL_TMPDIR-}" ]; then
    command rm -rf "${NVM_LOCAL_TMPDIR}"
  fi
  return 1
}

# args: flavor, kind, version
nvm_get_download_slug() {
  local NVM_LOCAL_FLAVOR
  case "${1-}" in
    node | iojs) NVM_LOCAL_FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 1
    ;;
  esac

  local NVM_LOCAL_KIND
  case "${2-}" in
    binary | source) NVM_LOCAL_KIND="${2}" ;;
    *)
      nvm_err 'supported kinds: binary, source'
      return 2
    ;;
  esac

  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${3-}"

  local NVM_LOCAL_OS
  NVM_LOCAL_OS="$(nvm_get_os)"

  local NVM_LOCAL_ARCH
  NVM_LOCAL_ARCH="$(nvm_get_arch)"
  if ! nvm_is_merged_node_version "${NVM_LOCAL_VERSION}"; then
    if [ "${NVM_LOCAL_ARCH}" = 'armv6l' ] || [ "${NVM_LOCAL_ARCH}" = 'armv7l' ]; then
      NVM_LOCAL_ARCH="arm-pi"
    fi
  fi

  # If node version in below 16.0.0 then there is no arm64 packages available in node repositories, so we have to install "x64" arch packages
  # If running MAC M1 :: arm64 arch and Darwin OS then use "x64" Architecture because node doesn't provide darwin_arm64 package below v16.0.0
  if nvm_version_greater '16.0.0' "${NVM_LOCAL_VERSION}"; then
    if [ "_${NVM_LOCAL_OS}" = '_darwin' ] && [ "${NVM_LOCAL_ARCH}" = 'arm64' ]; then
      NVM_LOCAL_ARCH=x64
    fi
  fi

  if [ "${NVM_LOCAL_KIND}" = 'binary' ]; then
    nvm_echo "${NVM_LOCAL_FLAVOR}-${NVM_LOCAL_VERSION}-${NVM_LOCAL_OS}-${NVM_LOCAL_ARCH}"
  elif [ "${NVM_LOCAL_KIND}" = 'source' ]; then
    nvm_echo "${NVM_LOCAL_FLAVOR}-${NVM_LOCAL_VERSION}"
  fi
}

nvm_get_artifact_compression() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${1-}"

  local NVM_LOCAL_OS
  NVM_LOCAL_OS="$(nvm_get_os)"

  local NVM_LOCAL_COMPRESSION
  NVM_LOCAL_COMPRESSION='tar.gz'
  if [ "_${NVM_LOCAL_OS}" = '_win' ]; then
    NVM_LOCAL_COMPRESSION='zip'
  elif nvm_supports_xz "${NVM_LOCAL_VERSION}"; then
    NVM_LOCAL_COMPRESSION='tar.xz'
  fi

  nvm_echo "${NVM_LOCAL_COMPRESSION}"
}

# args: flavor, kind, type, version
nvm_download_artifact() {
  local NVM_LOCAL_FLAVOR
  case "${1-}" in
    node | iojs) NVM_LOCAL_FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 1
    ;;
  esac

  local NVM_LOCAL_KIND
  case "${2-}" in
    binary | source) NVM_LOCAL_KIND="${2}" ;;
    *)
      nvm_err 'supported kinds: binary, source'
      return 1
    ;;
  esac

  local NVM_LOCAL_TYPE
  NVM_LOCAL_TYPE="${3-}"

  local NVM_LOCAL_MIRROR
  NVM_LOCAL_MIRROR="$(nvm_get_mirror "${NVM_LOCAL_FLAVOR}" "${NVM_LOCAL_TYPE}")"
  if [ -z "${NVM_LOCAL_MIRROR}" ]; then
    return 2
  fi

  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${4}"

  if [ -z "${NVM_LOCAL_VERSION}" ]; then
    nvm_err 'A version number is required.'
    return 3
  fi

  if [ "${NVM_LOCAL_KIND}" = 'binary' ] && ! nvm_binary_available "${NVM_LOCAL_VERSION}"; then
    nvm_err "No precompiled binary available for ${NVM_LOCAL_VERSION}."
    return
  fi

  local NVM_LOCAL_SLUG
  NVM_LOCAL_SLUG="$(nvm_get_download_slug "${NVM_LOCAL_FLAVOR}" "${NVM_LOCAL_KIND}" "${NVM_LOCAL_VERSION}")"

  local NVM_LOCAL_COMPRESSION
  NVM_LOCAL_COMPRESSION="$(nvm_get_artifact_compression "${NVM_LOCAL_VERSION}")"

  local NVM_LOCAL_CHECKSUM
  NVM_LOCAL_CHECKSUM="$(nvm_get_checksum "${NVM_LOCAL_FLAVOR}" "${NVM_LOCAL_TYPE}" "${NVM_LOCAL_VERSION}" "${NVM_LOCAL_SLUG}" "${NVM_LOCAL_COMPRESSION}")"

  local NVM_LOCAL_TMPDIR
  if [ "${NVM_LOCAL_KIND}" = 'binary' ]; then
    NVM_LOCAL_TMPDIR="$(nvm_cache_dir)/bin/${NVM_LOCAL_SLUG}"
  else
    NVM_LOCAL_TMPDIR="$(nvm_cache_dir)/src/${NVM_LOCAL_SLUG}"
  fi
  command mkdir -p "${NVM_LOCAL_TMPDIR}/files" || (
    nvm_err "creating directory ${NVM_LOCAL_TMPDIR}/files failed"
    return 3
  )

  local NVM_LOCAL_TARBALL
  NVM_LOCAL_TARBALL="${NVM_LOCAL_TMPDIR}/${NVM_LOCAL_SLUG}.${NVM_LOCAL_COMPRESSION}"
  local NVM_LOCAL_TARBALL_URL
  if nvm_version_greater_than_or_equal_to "${NVM_LOCAL_VERSION}" 0.1.14; then
    NVM_LOCAL_TARBALL_URL="${NVM_LOCAL_MIRROR}/${NVM_LOCAL_VERSION}/${NVM_LOCAL_SLUG}.${NVM_LOCAL_COMPRESSION}"
  else
    # node <= 0.1.13 does not have a directory
    NVM_LOCAL_TARBALL_URL="${NVM_LOCAL_MIRROR}/${NVM_LOCAL_SLUG}.${NVM_LOCAL_COMPRESSION}"
  fi

  if [ -r "${NVM_LOCAL_TARBALL}" ]; then
    nvm_err "Local cache found: $(nvm_sanitize_path "${NVM_LOCAL_TARBALL}")"
    if nvm_compare_checksum "${NVM_LOCAL_TARBALL}" "${NVM_LOCAL_CHECKSUM}" >/dev/null 2>&1; then
      nvm_err "Checksums match! Using existing downloaded archive $(nvm_sanitize_path "${NVM_LOCAL_TARBALL}")"
      nvm_echo "${NVM_LOCAL_TARBALL}"
      return 0
    fi
    nvm_compare_checksum "${NVM_LOCAL_TARBALL}" "${NVM_LOCAL_CHECKSUM}"
    nvm_err "Checksum check failed!"
    nvm_err "Removing the broken local cache..."
    command rm -rf "${NVM_LOCAL_TARBALL}"
  fi
  nvm_err "Downloading ${NVM_LOCAL_TARBALL_URL}..."
  nvm_download -L -C - "${NVM_LOCAL_PROGRESS_BAR}" "${NVM_LOCAL_TARBALL_URL}" -o "${NVM_LOCAL_TARBALL}" || (
    command rm -rf "${NVM_LOCAL_TARBALL}" "${NVM_LOCAL_TMPDIR}"
    nvm_err "Binary download from ${NVM_LOCAL_TARBALL_URL} failed, trying source."
    return 4
  )

  if nvm_grep '404 Not Found' "${NVM_LOCAL_TARBALL}" >/dev/null; then
    command rm -rf "${NVM_LOCAL_TARBALL}" "${NVM_LOCAL_TMPDIR}"
    nvm_err "HTTP 404 at URL ${NVM_LOCAL_TARBALL_URL}"
    return 5
  fi

  nvm_compare_checksum "${NVM_LOCAL_TARBALL}" "${NVM_LOCAL_CHECKSUM}" || (
    command rm -rf "${NVM_LOCAL_TMPDIR}/files"
    return 6
  )

  nvm_echo "${NVM_LOCAL_TARBALL}"
}

# args: nvm_os, version, tarball, tmpdir
nvm_extract_tarball() {
  if [ "$#" -ne 4 ]; then
    nvm_err 'nvm_extract_tarball requires exactly 4 arguments'
    return 5
  fi

  local NVM_LOCAL_OS
  NVM_LOCAL_OS="${1-}"

  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${2-}"

  local NVM_LOCAL_TARBALL
  NVM_LOCAL_TARBALL="${3-}"

  local NVM_LOCAL_TMPDIR
  NVM_LOCAL_TMPDIR="${4-}"

  local NVM_LOCAL_TAR_COMPRESSION_FLAG
  NVM_LOCAL_TAR_COMPRESSION_FLAG='z'
  if nvm_supports_xz "${NVM_LOCAL_VERSION}"; then
    NVM_LOCAL_TAR_COMPRESSION_FLAG='J'
  fi

  local NVM_LOCAL_TOOL_TAR
  NVM_LOCAL_TOOL_TAR='tar'
  if [ "${NVM_LOCAL_OS}" = 'aix' ]; then
    NVM_LOCAL_TOOL_TAR='gtar'
  fi

  if [ "${NVM_LOCAL_OS}" = 'openbsd' ]; then
    if [ "${NVM_LOCAL_TAR_COMPRESSION_FLAG}" = 'J' ]; then
      command xzcat "${NVM_LOCAL_TARBALL}" | "${NVM_LOCAL_TOOL_TAR}" -xf - -C "${NVM_LOCAL_TMPDIR}" -s '/[^\/]*\///' || return 1
    else
      command "${NVM_LOCAL_TOOL_TAR}" -x${NVM_LOCAL_TAR_COMPRESSION_FLAG}f "${NVM_LOCAL_TARBALL}" -C "${NVM_LOCAL_TMPDIR}" -s '/[^\/]*\///' || return 1
    fi
  else
    command "${NVM_LOCAL_TOOL_TAR}" -x${NVM_LOCAL_TAR_COMPRESSION_FLAG}f "${NVM_LOCAL_TARBALL}" -C "${NVM_LOCAL_TMPDIR}" --strip-components 1 || return 1
  fi
}

nvm_get_make_jobs() {
  if nvm_is_natural_num "${1-}"; then
    NVM_LOCAL_MAKE_JOBS="$1"
    nvm_echo "number of \`make\` jobs: ${NVM_LOCAL_MAKE_JOBS}"
    return
  elif [ -n "${1-}" ]; then
    unset NVM_LOCAL_MAKE_JOBS
    nvm_err "$1 is invalid for number of \`make\` jobs, must be a natural number"
  fi
  local NVM_LOCAL_OS
  NVM_LOCAL_OS="$(nvm_get_os)"
  local NVM_LOCAL_CPU_CORES
  case "_${NVM_LOCAL_OS}" in
    "_linux")
      NVM_LOCAL_CPU_CORES="$(nvm_grep -c -E '^processor.+: [0-9]+' /proc/cpuinfo)"
    ;;
    "_freebsd" | "_darwin" | "_openbsd")
      NVM_LOCAL_CPU_CORES="$(sysctl -n hw.ncpu)"
    ;;
    "_sunos")
      NVM_LOCAL_CPU_CORES="$(psrinfo | wc -l)"
    ;;
    "_aix")
      NVM_LOCAL_CPU_CORES="$(pmcycles -m | wc -l)"
    ;;
  esac
  if ! nvm_is_natural_num "${NVM_LOCAL_CPU_CORES}"; then
    nvm_err 'Can not determine how many core(s) are available, running in single-threaded mode.'
    nvm_err 'Please report an issue on GitHub to help us make nvm run faster on your computer!'
    NVM_LOCAL_MAKE_JOBS=1
  else
    nvm_echo "Detected that you have ${NVM_LOCAL_CPU_CORES} CPU core(s)"
    if [ "${NVM_LOCAL_CPU_CORES}" -gt 2 ]; then
      NVM_LOCAL_MAKE_JOBS=$((NVM_LOCAL_CPU_CORES - 1))
      nvm_echo "Running with ${NVM_LOCAL_MAKE_JOBS} threads to speed up the build"
    else
      NVM_LOCAL_MAKE_JOBS=1
      nvm_echo 'Number of CPU core(s) less than or equal to 2, running in single-threaded mode'
    fi
  fi
}

# args: flavor, type, version, make jobs, additional
nvm_install_source() {
  local NVM_LOCAL_FLAVOR
  case "${1-}" in
    node | iojs) NVM_LOCAL_FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 4
    ;;
  esac

  local NVM_LOCAL_TYPE
  NVM_LOCAL_TYPE="${2-}"

  local NVM_LOCAL_PREFIXED_VERSION
  NVM_LOCAL_PREFIXED_VERSION="${3-}"
  if [ -z "${NVM_LOCAL_PREFIXED_VERSION}" ]; then
    nvm_err 'A version number is required.'
    return 3
  fi

  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="$(nvm_strip_iojs_prefix "${NVM_LOCAL_PREFIXED_VERSION}")"

  local NVM_LOCAL_MAKE_JOBS
  NVM_LOCAL_MAKE_JOBS="${4-}"

  local NVM_LOCAL_ADDITIONAL_PARAMETERS
  NVM_LOCAL_ADDITIONAL_PARAMETERS="${5-}"

  local NVM_LOCAL_ARCH
  NVM_LOCAL_ARCH="$(nvm_get_arch)"
  if [ "${NVM_LOCAL_ARCH}" = 'armv6l' ] || [ "${NVM_LOCAL_ARCH}" = 'armv7l' ]; then
    if [ -n "${NVM_LOCAL_ADDITIONAL_PARAMETERS}" ]; then
      NVM_LOCAL_ADDITIONAL_PARAMETERS="--without-snapshot ${NVM_LOCAL_ADDITIONAL_PARAMETERS}"
    else
      NVM_LOCAL_ADDITIONAL_PARAMETERS='--without-snapshot'
    fi
  fi

  if [ -n "${NVM_LOCAL_ADDITIONAL_PARAMETERS}" ]; then
    nvm_echo "Additional options while compiling: ${NVM_LOCAL_ADDITIONAL_PARAMETERS}"
  fi

  local NVM_LOCAL_OS
  NVM_LOCAL_OS="$(nvm_get_os)"

  local NVM_LOCAL_TOOL_MAKE
  NVM_LOCAL_TOOL_MAKE='make'
  local NVM_LOCAL_MAKE_CXX
  case "${NVM_LOCAL_OS}" in
    'freebsd' | 'openbsd')
      NVM_LOCAL_TOOL_MAKE='gmake'
      NVM_LOCAL_MAKE_CXX="CC=${CC:-cc} CXX=${CXX:-c++}"
    ;;
    'darwin')
      NVM_LOCAL_MAKE_CXX="CC=${CC:-cc} CXX=${CXX:-c++}"
    ;;
    'aix')
      NVM_LOCAL_TOOL_MAKE='gmake'
    ;;
  esac
  if nvm_has "clang++" && nvm_has "clang" && nvm_version_greater_than_or_equal_to "$(nvm_clang_version)" 3.5; then
    if [ -z "${CC-}" ] || [ -z "${CXX-}" ]; then
      nvm_echo "Clang v3.5+ detected! CC or CXX not specified, will use Clang as C/C++ compiler!"
      NVM_LOCAL_MAKE_CXX="CC=${CC:-cc} CXX=${CXX:-c++}"
    fi
  fi

  local NVM_LOCAL_TARBALL
  local NVM_LOCAL_TMPDIR
  local NVM_LOCAL_VERSION_PATH

  if [ "${NVM_NO_PROGRESS-}" = "1" ]; then
    # --silent, --show-error, use short option as @samrocketman mentions the compatibility issue.
    NVM_LOCAL_PROGRESS_BAR="-sS"
  else
    NVM_LOCAL_PROGRESS_BAR="--progress-bar"
  fi

  nvm_is_zsh && setopt local_options shwordsplit

  NVM_LOCAL_TARBALL="$(NVM_LOCAL_PROGRESS_BAR="${NVM_LOCAL_PROGRESS_BAR}" nvm_download_artifact "${NVM_LOCAL_FLAVOR}" source "${NVM_LOCAL_TYPE}" "${NVM_LOCAL_VERSION}" | command tail -1)" && \
  [ -f "${NVM_LOCAL_TARBALL}" ] && \
  NVM_LOCAL_TMPDIR="$(dirname "${NVM_LOCAL_TARBALL}")/files" && \
  if ! (
    # shellcheck disable=SC2086
    command mkdir -p "${NVM_LOCAL_TMPDIR}" && \
    nvm_extract_tarball "${NVM_LOCAL_OS}" "${NVM_LOCAL_VERSION}" "${NVM_LOCAL_TARBALL}" "${NVM_LOCAL_TMPDIR}" && \
    NVM_LOCAL_VERSION_PATH="$(nvm_version_path "${NVM_LOCAL_PREFIXED_VERSION}")" && \
    nvm_cd "${NVM_LOCAL_TMPDIR}" && \
    nvm_echo '$>'./configure --prefix="${NVM_LOCAL_VERSION_PATH}" ${NVM_LOCAL_ADDITIONAL_PARAMETERS}'<' && \
    ./configure --prefix="${NVM_LOCAL_VERSION_PATH}" ${NVM_LOCAL_ADDITIONAL_PARAMETERS} && \
    ${NVM_LOCAL_TOOL_MAKE} -j "${NVM_LOCAL_MAKE_JOBS}" ${NVM_LOCAL_MAKE_CXX-} && \
    command rm -f "${NVM_LOCAL_VERSION_PATH}" 2>/dev/null && \
    ${NVM_LOCAL_TOOL_MAKE} -j "${NVM_LOCAL_MAKE_JOBS}" ${NVM_LOCAL_MAKE_CXX-} install
  ); then
    nvm_err "nvm: install ${NVM_LOCAL_VERSION} failed!"
    command rm -rf "${NVM_LOCAL_TMPDIR-}"
    return 1
  fi
}

nvm_use_if_needed() {
  if [ "_${1-}" = "_$(nvm_ls_current)" ]; then
    return
  fi
  nvm use "$@"
}

nvm_install_npm_if_needed() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="$(nvm_ls_current)"
  if ! nvm_has "npm"; then
    nvm_echo 'Installing npm...'
    if nvm_version_greater 0.2.0 "${NVM_LOCAL_VERSION}"; then
      nvm_err 'npm requires node v0.2.3 or higher'
    elif nvm_version_greater_than_or_equal_to "${NVM_LOCAL_VERSION}" 0.2.0; then
      if nvm_version_greater 0.2.3 "${NVM_LOCAL_VERSION}"; then
        nvm_err 'npm requires node v0.2.3 or higher'
      else
        nvm_download -L https://npmjs.org/install.sh -o - | clean=yes npm_install=0.2.19 sh
      fi
    else
      nvm_download -L https://npmjs.org/install.sh -o - | clean=yes sh
    fi
  fi
  return $?
}

nvm_match_version() {
  local NVM_LOCAL_IOJS_PREFIX
  NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_LOCAL_PROVIDED_VERSION
  NVM_LOCAL_PROVIDED_VERSION="$1"
  case "_${NVM_LOCAL_PROVIDED_VERSION}" in
    "_${NVM_LOCAL_IOJS_PREFIX}" | '_io.js')
      nvm_version "${NVM_LOCAL_IOJS_PREFIX}"
    ;;
    '_system')
      nvm_echo 'system'
    ;;
    *)
      nvm_version "${NVM_LOCAL_PROVIDED_VERSION}"
    ;;
  esac
}

nvm_npm_global_modules() {
  local NVM_LOCAL_NPMLIST
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="$1"
  NVM_LOCAL_NPMLIST=$(nvm use "${NVM_LOCAL_VERSION}" >/dev/null && npm list -g --depth=0 2>/dev/null | command sed 1,1d | nvm_grep -v 'UNMET PEER DEPENDENCY')

  local NVM_LOCAL_INSTALLS
  NVM_LOCAL_INSTALLS=$(nvm_echo "${NVM_LOCAL_NPMLIST}" | command sed -e '/ -> / d' -e '/\(empty\)/ d' -e 's/^.* \(.*@[^ ]*\).*/\1/' -e '/^npm@[^ ]*.*$/ d' | command xargs)

  local NVM_LOCAL_LINKS
  NVM_LOCAL_LINKS="$(nvm_echo "${NVM_LOCAL_NPMLIST}" | command sed -n 's/.* -> \(.*\)/\1/ p')"

  nvm_echo "${NVM_LOCAL_INSTALLS} //// ${NVM_LOCAL_LINKS}"
}

nvm_npmrc_bad_news_bears() {
  local NVM_LOCAL_NPMRC
  NVM_LOCAL_NPMRC="${1-}"
  if [ -n "${NVM_LOCAL_NPMRC}" ] && [ -f "${NVM_LOCAL_NPMRC}" ] && nvm_grep -Ee '^(prefix|globalconfig) *=' <"${NVM_LOCAL_NPMRC}" >/dev/null; then
    return 0
  fi
  return 1
}

nvm_die_on_prefix() {
  local NVM_LOCAL_DELETE_PREFIX
  NVM_LOCAL_DELETE_PREFIX="${1-}"
  case "${NVM_LOCAL_DELETE_PREFIX}" in
    0 | 1) ;;
    *)
      nvm_err 'First argument "delete the prefix" must be zero or one'
      return 1
    ;;
  esac
  local NVM_LOCAL_COMMAND
  NVM_LOCAL_COMMAND="${2-}"
  local NVM_LOCAL_VERSION_DIR
  NVM_LOCAL_VERSION_DIR="${3-}"
  if [ -z "${NVM_LOCAL_COMMAND}" ] || [ -z "${NVM_LOCAL_VERSION_DIR}" ]; then
    nvm_err 'Second argument "nvm command", and third argument "nvm version dir", must both be nonempty'
    return 2
  fi

  # npm first looks at ${PREFIX} (case-sensitive)
  # we do not bother to test the value here; if this env var is set, unset it to continue.
  # however, `npm exec` in npm v7.2+ sets ${PREFIX}; if set, inherit it
  if [ -n "${PREFIX-}" ] && [ "$(nvm_version_path "$(node -v)")" != "${PREFIX}" ]; then
    nvm deactivate >/dev/null 2>&1
    nvm_err "nvm is not compatible with the \"PREFIX\" environment variable: currently set to \"${PREFIX}\""
    nvm_err 'Run `unset PREFIX` to unset it.'
    return 3
  fi

  local NVM_LOCAL_OS
  NVM_LOCAL_OS="$(nvm_get_os)"

  # npm normalizes NPM_CONFIG_-prefixed env vars
  # https://github.com/npm/npmconf/blob/22827e4038d6eebaafeb5c13ed2b92cf97b8fb82/npmconf.js#L331-L348
  # https://github.com/npm/npm/blob/5e426a78ca02d0044f8dd26e0c5f881217081cbd/lib/config/core.js#L343-L359
  #
  # here, we avoid trying to replicate "which one wins" or testing the value; if any are defined, it errors
  # until none are left.
  local NVM_LOCAL_NPM_CONFIG_x_PREFIX_ENV
  NVM_LOCAL_NPM_CONFIG_x_PREFIX_ENV="$(command awk 'BEGIN { for (name in ENVIRON) if (toupper(name) == "NPM_CONFIG_PREFIX") { print name; break } }')"
  if [ -n "${NVM_LOCAL_NPM_CONFIG_x_PREFIX_ENV-}" ]; then
    local NVM_LOCAL_CONFIG_VALUE
    eval "NVM_LOCAL_CONFIG_VALUE=\"\$${NVM_LOCAL_NPM_CONFIG_x_PREFIX_ENV}\""
    if [ -n "${NVM_LOCAL_CONFIG_VALUE-}" ] && [ "_${NVM_LOCAL_OS}" = "_win" ]; then
      NVM_LOCAL_CONFIG_VALUE="$(cd "${NVM_LOCAL_CONFIG_VALUE}" 2>/dev/null && pwd)"
    fi
    if [ -n "${NVM_LOCAL_CONFIG_VALUE-}" ] && ! nvm_tree_contains_path "${NVM_DIR}" "${NVM_LOCAL_CONFIG_VALUE}"; then
      nvm deactivate >/dev/null 2>&1
      nvm_err "nvm is not compatible with the \"${NVM_LOCAL_NPM_CONFIG_x_PREFIX_ENV}\" environment variable: currently set to \"${NVM_LOCAL_CONFIG_VALUE}\""
      nvm_err "Run \`unset ${NVM_LOCAL_NPM_CONFIG_x_PREFIX_ENV}\` to unset it."
      return 4
    fi
  fi

  # here, npm config checks npmrc files.
  # the stack is: cli, env, project, user, global, builtin, defaults
  # cli does not apply; env is covered above, defaults don't exist for prefix
  # there are 4 npmrc locations to check: project, global, user, and builtin
  # project: find the closest node_modules or package.json-containing dir, `.npmrc`
  # global: default prefix + `/etc/npmrc`
  # user: ${HOME}/.npmrc
  # builtin: npm install location, `npmrc`
  #
  # if any of them have a `prefix`, fail.
  # if any have `globalconfig`, fail also, just in case, to avoid spidering configs.

  local NVM_LOCAL_NPM_BUILTIN_NPMRC
  NVM_LOCAL_NPM_BUILTIN_NPMRC="${NVM_LOCAL_VERSION_DIR}/lib/node_modules/npm/npmrc"
  if nvm_npmrc_bad_news_bears "${NVM_LOCAL_NPM_BUILTIN_NPMRC}"; then
    if [ "_${NVM_LOCAL_DELETE_PREFIX}" = "_1" ]; then
      npm config --loglevel=warn delete prefix --userconfig="${NVM_LOCAL_NPM_BUILTIN_NPMRC}"
      npm config --loglevel=warn delete globalconfig --userconfig="${NVM_LOCAL_NPM_BUILTIN_NPMRC}"
    else
      nvm_err "Your builtin npmrc file ($(nvm_sanitize_path "${NVM_LOCAL_NPM_BUILTIN_NPMRC}"))"
      nvm_err 'has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.'
      nvm_err "Run \`${NVM_LOCAL_COMMAND}\` to unset it."
      return 10
    fi
  fi

  local NVM_LOCAL_NPM_GLOBAL_NPMRC
  NVM_LOCAL_NPM_GLOBAL_NPMRC="${NVM_LOCAL_VERSION_DIR}/etc/npmrc"
  if nvm_npmrc_bad_news_bears "${NVM_LOCAL_NPM_GLOBAL_NPMRC}"; then
    if [ "_${NVM_LOCAL_DELETE_PREFIX}" = "_1" ]; then
      npm config --global --loglevel=warn delete prefix
      npm config --global --loglevel=warn delete globalconfig
    else
      nvm_err "Your global npmrc file ($(nvm_sanitize_path "${NVM_LOCAL_NPM_GLOBAL_NPMRC}"))"
      nvm_err 'has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.'
      nvm_err "Run \`${NVM_LOCAL_COMMAND}\` to unset it."
      return 10
    fi
  fi

  local NVM_LOCAL_NPM_USER_NPMRC
  NVM_LOCAL_NPM_USER_NPMRC="${HOME}/.npmrc"
  if nvm_npmrc_bad_news_bears "${NVM_LOCAL_NPM_USER_NPMRC}"; then
    if [ "_${NVM_LOCAL_DELETE_PREFIX}" = "_1" ]; then
      npm config --loglevel=warn delete prefix --userconfig="${NVM_LOCAL_NPM_USER_NPMRC}"
      npm config --loglevel=warn delete globalconfig --userconfig="${NVM_LOCAL_NPM_USER_NPMRC}"
    else
      nvm_err "Your user’s .npmrc file ($(nvm_sanitize_path "${NVM_LOCAL_NPM_USER_NPMRC}"))"
      nvm_err 'has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.'
      nvm_err "Run \`${NVM_LOCAL_COMMAND}\` to unset it."
      return 10
    fi
  fi

  local NVM_LOCAL_NPM_PROJECT_NPMRC
  NVM_LOCAL_NPM_PROJECT_NPMRC="$(nvm_find_project_dir)/.npmrc"
  if nvm_npmrc_bad_news_bears "${NVM_LOCAL_NPM_PROJECT_NPMRC}"; then
    if [ "_${NVM_LOCAL_DELETE_PREFIX}" = "_1" ]; then
      npm config --loglevel=warn delete prefix
      npm config --loglevel=warn delete globalconfig
    else
      nvm_err "Your project npmrc file ($(nvm_sanitize_path "${NVM_LOCAL_NPM_PROJECT_NPMRC}"))"
      nvm_err 'has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.'
      nvm_err "Run \`${NVM_LOCAL_COMMAND}\` to unset it."
      return 10
    fi
  fi
}

# Succeeds if ${NVM_LOCAL_IOJS_VERSION} represents an io.js version that has a
# Solaris binary, fails otherwise.
# Currently, only io.js 3.3.1 has a Solaris binary available, and it's the
# latest io.js version available. The expectation is that any potential io.js
# version later than v3.3.1 will also have Solaris binaries.
nvm_iojs_version_has_solaris_binary() {
  local NVM_LOCAL_IOJS_VERSION
  NVM_LOCAL_IOJS_VERSION="$1"
  local NVM_LOCAL_STRIPPED_IOJS_VERSION
  NVM_LOCAL_STRIPPED_IOJS_VERSION="$(nvm_strip_iojs_prefix "${NVM_LOCAL_IOJS_VERSION}")"
  if [ "_${NVM_LOCAL_STRIPPED_IOJS_VERSION}" = "${NVM_LOCAL_IOJS_VERSION}" ]; then
    return 1
  fi

  # io.js started shipping Solaris binaries with io.js v3.3.1
  nvm_version_greater_than_or_equal_to "${NVM_LOCAL_STRIPPED_IOJS_VERSION}" v3.3.1
}

# Succeeds if ${NVM_LOCAL_NODE_VERSION} represents a node version that has a
# Solaris binary, fails otherwise.
# Currently, node versions starting from v0.8.6 have a Solaris binary
# available.
nvm_node_version_has_solaris_binary() {
  local NVM_LOCAL_NODE_VERSION
  NVM_LOCAL_NODE_VERSION="$1"
  # Error out if ${NVM_LOCAL_NODE_VERSION} is actually an io.js version
  local NVM_LOCAL_STRIPPED_IOJS_VERSION
  NVM_LOCAL_STRIPPED_IOJS_VERSION="$(nvm_strip_iojs_prefix "${NVM_LOCAL_NODE_VERSION}")"
  if [ "_${NVM_LOCAL_STRIPPED_IOJS_VERSION}" != "_${NVM_LOCAL_NODE_VERSION}" ]; then
    return 1
  fi

  # node (unmerged) started shipping Solaris binaries with v0.8.6 and
  # node versions v1.0.0 or greater are not considered valid "unmerged" node
  # versions.
  nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" v0.8.6 \
  && ! nvm_version_greater_than_or_equal_to "${NVM_LOCAL_NODE_VERSION}" v1.0.0
}

# Succeeds if ${NVM_LOCAL_VERSION} represents a version (node, io.js or merged) that has a
# Solaris binary, fails otherwise.
nvm_has_solaris_binary() {
  local NVM_LOCAL_VERSION
  NVM_LOCAL_VERSION="${1-}"
  if nvm_is_merged_node_version "${NVM_LOCAL_VERSION}"; then
    return 0 # All merged node versions have a Solaris binary
  elif nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
    nvm_iojs_version_has_solaris_binary "${NVM_LOCAL_VERSION}"
  else
    nvm_node_version_has_solaris_binary "${NVM_LOCAL_VERSION}"
  fi
}

nvm_sanitize_path() {
  local NVM_LOCAL_SANITIZED_PATH
  NVM_LOCAL_SANITIZED_PATH="${1-}"
  if [ "_${NVM_LOCAL_SANITIZED_PATH}" != "_${NVM_DIR}" ]; then
    NVM_LOCAL_SANITIZED_PATH="$(nvm_echo "${NVM_LOCAL_SANITIZED_PATH}" | command sed -e "s#${NVM_DIR}#\${NVM_DIR}#g")"
  fi
  if [ "_${NVM_LOCAL_SANITIZED_PATH}" != "_${HOME}" ]; then
    NVM_LOCAL_SANITIZED_PATH="$(nvm_echo "${NVM_LOCAL_SANITIZED_PATH}" | command sed -e "s#${HOME}#\${HOME}#g")"
  fi
  nvm_echo "${NVM_LOCAL_SANITIZED_PATH}"
}

nvm_is_natural_num() {
  if [ -z "$1" ]; then
    return 4
  fi
  case "$1" in
    0) return 1 ;;
    -*) return 3 ;; # some BSDs return false positives for double-negated args
    *)
      [ "$1" -eq "$1" ] 2>/dev/null # returns 2 if it doesn't match
    ;;
  esac
}

# Check version dir permissions
nvm_check_file_permissions() {
  nvm_is_zsh && setopt local_options nonomatch
  for FILE in "$1"/* "$1"/.[!.]* "$1"/..?* ; do
    if [ -d "${FILE}" ]; then
      if [ -n "${NVM_DEBUG-}" ]; then
        nvm_err "${FILE}"
      fi
      if ! nvm_check_file_permissions "${FILE}"; then
        return 2
      fi
    elif [ -e "${FILE}" ] && [ ! -w "${FILE}" ] && [ ! -O "${FILE}" ]; then
      nvm_err "file is not writable or self-owned: $(nvm_sanitize_path "${FILE}")"
      return 1
    fi
  done
  return 0
}

nvm_cache_dir() {
  nvm_echo "${NVM_DIR}/.cache"
}

nvm() {
  if [ "$#" -lt 1 ]; then
    nvm --help
    return
  fi

  local NVM_LOCAL_DEFAULT_IFS
  NVM_LOCAL_DEFAULT_IFS=" $(nvm_echo t | command tr t \\t)
"
  if [ "${-#*e}" != "$-" ]; then
    set +e
    local NVM_LOCAL_EXIT_CODE
    IFS="${NVM_LOCAL_DEFAULT_IFS}" nvm "$@"
    NVM_LOCAL_EXIT_CODE="$?"
    set -e
    return "${NVM_LOCAL_EXIT_CODE}"
  elif [ "${-#*a}" != "$-" ]; then
    set +a
    local NVM_LOCAL_EXIT_CODE
    IFS="${NVM_LOCAL_DEFAULT_IFS}" nvm "$@"
    NVM_LOCAL_EXIT_CODE="$?"
    set -a
    return "${NVM_LOCAL_EXIT_CODE}"
  elif [ -n "${BASH-}" ] && [ "${-#*E}" != "$-" ]; then
    # shellcheck disable=SC3041
    set +E
    local NVM_LOCAL_EXIT_CODE
    IFS="${NVM_LOCAL_DEFAULT_IFS}" nvm "$@"
    NVM_LOCAL_EXIT_CODE="$?"
    # shellcheck disable=SC3041
    set -E
    return "${NVM_LOCAL_EXIT_CODE}"
  elif [ "${IFS}" != "${NVM_LOCAL_DEFAULT_IFS}" ]; then
    IFS="${NVM_LOCAL_DEFAULT_IFS}" nvm "$@"
    return "$?"
  fi

  local NVM_LOCAL_I
  for NVM_LOCAL_I in "$@"; do
    case ${NVM_LOCAL_I} in
      --) break ;;
      '-h'|'help'|'--help')
        NVM_NO_COLORS=""
        for NVM_LOCAL_J in "$@"; do
          if [ "${NVM_LOCAL_J}" = '--no-colors' ]; then
            NVM_NO_COLORS="${NVM_LOCAL_J}"
            break
          fi
        done

        local NVM_LOCAL_INITIAL_COLOR_INFO
        local NVM_LOCAL_RED_INFO
        local NVM_LOCAL_GREEN_INFO
        local NVM_LOCAL_BLUE_INFO
        local NVM_LOCAL_CYAN_INFO
        local NVM_LOCAL_MAGENTA_INFO
        local NVM_LOCAL_YELLOW_INFO
        local NVM_LOCAL_BLACK_INFO
        local NVM_LOCAL_GREY_WHITE_INFO

        if [ -z "${NVM_NO_COLORS-}"  ] && nvm_has_colors; then
          NVM_LOCAL_INITIAL_COLOR_INFO='\033[0;32m g\033[0m \033[0;34m b\033[0m \033[0;33m y\033[0m \033[0;31m r\033[0m \033[0;37m e\033[0m'
          NVM_LOCAL_RED_INFO='\033[0;31m r\033[0m/\033[1;31mR\033[0m = \033[0;31mred\033[0m / \033[1;31mbold red\033[0m'
          NVM_LOCAL_GREEN_INFO='\033[0;32m g\033[0m/\033[1;32mG\033[0m = \033[0;32mgreen\033[0m / \033[1;32mbold green\033[0m'
          NVM_LOCAL_BLUE_INFO='\033[0;34m b\033[0m/\033[1;34mB\033[0m = \033[0;34mblue\033[0m / \033[1;34mbold blue\033[0m'
          NVM_LOCAL_CYAN_INFO='\033[0;36m c\033[0m/\033[1;36mC\033[0m = \033[0;36mcyan\033[0m / \033[1;36mbold cyan\033[0m'
          NVM_LOCAL_MAGENTA_INFO='\033[0;35m m\033[0m/\033[1;35mM\033[0m = \033[0;35mmagenta\033[0m / \033[1;35mbold magenta\033[0m'
          NVM_LOCAL_YELLOW_INFO='\033[0;33m y\033[0m/\033[1;33mY\033[0m = \033[0;33myellow\033[0m / \033[1;33mbold yellow\033[0m'
          NVM_LOCAL_BLACK_INFO='\033[0;30m k\033[0m/\033[1;30mK\033[0m = \033[0;30mblack\033[0m / \033[1;30mbold black\033[0m'
          NVM_LOCAL_GREY_WHITE_INFO='\033[0;37m e\033[0m/\033[1;37mW\033[0m = \033[0;37mlight grey\033[0m / \033[1;37mwhite\033[0m'
        else
          NVM_LOCAL_INITIAL_COLOR_INFO='gbYre'
          NVM_LOCAL_RED_INFO='r/R = red / bold red'
          NVM_LOCAL_GREEN_INFO='g/G = green / bold green'
          NVM_LOCAL_BLUE_INFO='b/B = blue / bold blue'
          NVM_LOCAL_CYAN_INFO='c/C = cyan / bold cyan'
          NVM_LOCAL_MAGENTA_INFO='m/M = magenta / bold magenta'
          NVM_LOCAL_YELLOW_INFO='y/Y = yellow / bold yellow'
          NVM_LOCAL_BLACK_INFO='k/K = black / bold black'
          NVM_LOCAL_GREY_WHITE_INFO='e/W = light grey / white'
        fi

        local NVM_LOCAL_IOJS_PREFIX
        NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
        local NVM_LOCAL_NODE_PREFIX
        NVM_LOCAL_NODE_PREFIX="$(nvm_node_prefix)"
        local NVM_LOCAL_VERSION
        NVM_LOCAL_VERSION="$(nvm --version)"
        nvm_echo
        nvm_echo "Node Version Manager (v${NVM_LOCAL_VERSION})"
        nvm_echo
        nvm_echo 'Note: <version> refers to any version-like string nvm understands. This includes:'
        nvm_echo '  - full or partial version numbers, starting with an optional "v" (0.10, v0.1.2, v1)'
        nvm_echo "  - default (built-in) aliases: ${NVM_LOCAL_NODE_PREFIX}, stable, unstable, ${NVM_LOCAL_IOJS_PREFIX}, system"
        nvm_echo '  - custom aliases you define with `nvm alias foo`'
        nvm_echo
        nvm_echo ' Any options that produce colorized output should respect the `--no-colors` option.'
        nvm_echo
        nvm_echo 'Usage:'
        nvm_echo '  nvm --help                                  Show this message'
        nvm_echo '    --no-colors                               Suppress colored output'
        nvm_echo '  nvm --version                               Print out the installed version of nvm'
        nvm_echo '  nvm install [<version>]                     Download and install a <version>. Uses .nvmrc if available and version is omitted.'
        nvm_echo '   The following optional arguments, if provided, must appear directly after `nvm install`:'
        nvm_echo '    -s                                        Skip binary download, install from source only.'
        nvm_echo '    -b                                        Skip source download, install from binary only.'
        nvm_echo '    --reinstall-packages-from=<version>       When installing, reinstall packages installed in <node|iojs|node version number>'
        nvm_echo '    --lts                                     When installing, only select from LTS (long-term support) versions'
        nvm_echo '    --lts=<LTS name>                          When installing, only select from versions for a specific LTS line'
        nvm_echo '    --skip-default-packages                   When installing, skip the default-packages file if it exists'
        nvm_echo '    --latest-npm                              After installing, attempt to upgrade to the latest working npm on the given node version'
        nvm_echo '    --no-progress                             Disable the progress bar on any downloads'
        nvm_echo '    --alias=<name>                            After installing, set the alias specified to the version specified. (same as: nvm alias <name> <version>)'
        nvm_echo '    --default                                 After installing, set default alias to the version specified. (same as: nvm alias default <version>)'
        nvm_echo '  nvm uninstall <version>                     Uninstall a version'
        nvm_echo '  nvm uninstall --lts                         Uninstall using automatic LTS (long-term support) alias `lts/*`, if available.'
        nvm_echo '  nvm uninstall --lts=<LTS name>              Uninstall using automatic alias for provided LTS line, if available.'
        nvm_echo '  nvm use [<version>]                         Modify PATH to use <version>. Uses .nvmrc if available and version is omitted.'
        nvm_echo '   The following optional arguments, if provided, must appear directly after `nvm use`:'
        nvm_echo '    --silent                                  Silences stdout/stderr output'
        nvm_echo '    --lts                                     Uses automatic LTS (long-term support) alias `lts/*`, if available.'
        nvm_echo '    --lts=<LTS name>                          Uses automatic alias for provided LTS line, if available.'
        nvm_echo '  nvm exec [<version>] [<command>]            Run <command> on <version>. Uses .nvmrc if available and version is omitted.'
        nvm_echo '   The following optional arguments, if provided, must appear directly after `nvm exec`:'
        nvm_echo '    --silent                                  Silences stdout/stderr output'
        nvm_echo '    --lts                                     Uses automatic LTS (long-term support) alias `lts/*`, if available.'
        nvm_echo '    --lts=<LTS name>                          Uses automatic alias for provided LTS line, if available.'
        nvm_echo '  nvm run [<version>] [<args>]                Run `node` on <version> with <args> as arguments. Uses .nvmrc if available and version is omitted.'
        nvm_echo '   The following optional arguments, if provided, must appear directly after `nvm run`:'
        nvm_echo '    --silent                                  Silences stdout/stderr output'
        nvm_echo '    --lts                                     Uses automatic LTS (long-term support) alias `lts/*`, if available.'
        nvm_echo '    --lts=<LTS name>                          Uses automatic alias for provided LTS line, if available.'
        nvm_echo '  nvm current                                 Display currently activated version of Node'
        nvm_echo '  nvm ls [<version>]                          List installed versions, matching a given <version> if provided'
        nvm_echo '    --no-colors                               Suppress colored output'
        nvm_echo '    --no-alias                                Suppress `nvm alias` output'
        nvm_echo '  nvm ls-remote [<version>]                   List remote versions available for install, matching a given <version> if provided'
        nvm_echo '    --lts                                     When listing, only show LTS (long-term support) versions'
        nvm_echo '    --lts=<LTS name>                          When listing, only show versions for a specific LTS line'
        nvm_echo '    --no-colors                               Suppress colored output'
        nvm_echo '  nvm version <version>                       Resolve the given description to a single local version'
        nvm_echo '  nvm version-remote <version>                Resolve the given description to a single remote version'
        nvm_echo '    --lts                                     When listing, only select from LTS (long-term support) versions'
        nvm_echo '    --lts=<LTS name>                          When listing, only select from versions for a specific LTS line'
        nvm_echo '  nvm deactivate                              Undo effects of `nvm` on current shell'
        nvm_echo '    --silent                                  Silences stdout/stderr output'
        nvm_echo '  nvm alias [<pattern>]                       Show all aliases beginning with <pattern>'
        nvm_echo '    --no-colors                               Suppress colored output'
        nvm_echo '  nvm alias <name> <version>                  Set an alias named <name> pointing to <version>'
        nvm_echo '  nvm unalias <name>                          Deletes the alias named <name>'
        nvm_echo '  nvm install-latest-npm                      Attempt to upgrade to the latest working `npm` on the current node version'
        nvm_echo '  nvm reinstall-packages <version>            Reinstall global `npm` packages contained in <version> to current version'
        nvm_echo '  nvm unload                                  Unload `nvm` from shell'
        nvm_echo '  nvm which [current | <version>]             Display path to installed node version. Uses .nvmrc if available and version is omitted.'
        nvm_echo '    --silent                                  Silences stdout/stderr output when a version is omitted'
        nvm_echo '  nvm cache dir                               Display path to the cache directory for nvm'
        nvm_echo '  nvm cache clear                             Empty cache directory for nvm'
        nvm_echo '  nvm set-colors [<color codes>]              Set five text colors using format "yMeBg". Available when supported.'
        nvm_echo '                                               Initial colors are:'
        nvm_echo_with_colors "                                                  ${NVM_LOCAL_INITIAL_COLOR_INFO}"
        nvm_echo '                                               Color codes:'
        nvm_echo_with_colors "                                                ${NVM_LOCAL_RED_INFO}"
        nvm_echo_with_colors "                                                ${NVM_LOCAL_GREEN_INFO}"
        nvm_echo_with_colors "                                                ${NVM_LOCAL_BLUE_INFO}"
        nvm_echo_with_colors "                                                ${NVM_LOCAL_CYAN_INFO}"
        nvm_echo_with_colors "                                                ${NVM_LOCAL_MAGENTA_INFO}"
        nvm_echo_with_colors "                                                ${NVM_LOCAL_YELLOW_INFO}"
        nvm_echo_with_colors "                                                ${NVM_LOCAL_BLACK_INFO}"
        nvm_echo_with_colors "                                                ${NVM_LOCAL_GREY_WHITE_INFO}"
        nvm_echo
        nvm_echo 'Example:'
        nvm_echo '  nvm install 8.0.0                     Install a specific version number'
        nvm_echo '  nvm use 8.0                           Use the latest available 8.0.x release'
        nvm_echo '  nvm run 6.10.3 app.js                 Run app.js using node 6.10.3'
        nvm_echo '  nvm exec 4.8.3 node app.js            Run `node app.js` with the PATH pointing to node 4.8.3'
        nvm_echo '  nvm alias default 8.1.0               Set default node version on a shell'
        nvm_echo '  nvm alias default node                Always default to the latest available node version on a shell'
        nvm_echo
        nvm_echo '  nvm install node                      Install the latest available version'
        nvm_echo '  nvm use node                          Use the latest version'
        nvm_echo '  nvm install --lts                     Install the latest LTS version'
        nvm_echo '  nvm use --lts                         Use the latest LTS version'
        nvm_echo
        nvm_echo '  nvm set-colors cgYmW                  Set text colors to cyan, green, bold yellow, magenta, and white'
        nvm_echo
        nvm_echo 'Note:'
        nvm_echo '  to remove, delete, or uninstall nvm - just remove the `${NVM_DIR}` folder (usually `~/.nvm`)'
        nvm_echo
        return 0;
      ;;
    esac
  done

  local NVM_LOCAL_COMMAND
  NVM_LOCAL_COMMAND="${1-}"
  shift

  # initialize local variables
  local NVM_LOCAL_VERSION
  local NVM_LOCAL_ADDITIONAL_PARAMETERS

  case ${NVM_LOCAL_COMMAND} in
    "cache")
      case "${1-}" in
        dir) nvm_cache_dir ;;
        clear)
          local NVM_LOCAL_DIR
          NVM_LOCAL_DIR="$(nvm_cache_dir)"
          if command rm -rf "${NVM_LOCAL_DIR}" && command mkdir -p "${NVM_LOCAL_DIR}"; then
            nvm_echo 'nvm cache cleared.'
          else
            nvm_err "Unable to clear nvm cache: ${NVM_LOCAL_DIR}"
            return 1
          fi
        ;;
        *)
          >&2 nvm --help
          return 127
        ;;
      esac
    ;;

    "debug")
      local NVM_LOCAL_OS_VERSION
      nvm_is_zsh && setopt local_options shwordsplit
      nvm_err "nvm --version: v$(nvm --version)"
      if [ -n "${TERM_PROGRAM-}" ]; then
        nvm_err "\${TERM_PROGRAM}: ${TERM_PROGRAM}"
      fi
      nvm_err "\${SHELL}: ${SHELL}"
      # shellcheck disable=SC2169,SC3028
      nvm_err "\${SHLVL}: ${SHLVL-}"
      nvm_err "whoami: '$(whoami)'"
      nvm_err "\${HOME}: ${HOME}"
      nvm_err "\${NVM_DIR}: '$(nvm_sanitize_path "${NVM_DIR}")'"
      nvm_err "\${PATH}: $(nvm_sanitize_path "${PATH}")"
      nvm_err "\${PREFIX}: '$(nvm_sanitize_path "${PREFIX}")'"
      nvm_err "\${NPM_CONFIG_PREFIX}: '$(nvm_sanitize_path "${NPM_CONFIG_PREFIX}")'"
      nvm_err "\${NVM_NODEJS_ORG_MIRROR}: '${NVM_NODEJS_ORG_MIRROR}'"
      nvm_err "\${NVM_IOJS_ORG_MIRROR}: '${NVM_IOJS_ORG_MIRROR}'"
      nvm_err "shell version: '$(${SHELL} --version | command head -n 1)'"
      nvm_err "uname -a: '$(command uname -a | command awk '{$2=""; print}' | command xargs)'"
      nvm_err "checksum binary: '$(nvm_get_checksum_binary 2>/dev/null)'"
      if [ "$(nvm_get_os)" = "darwin" ] && nvm_has sw_vers; then
        NVM_LOCAL_OS_VERSION="$(sw_vers | command awk '{print $2}' | command xargs)"
      elif [ -r "/etc/issue" ]; then
        NVM_LOCAL_OS_VERSION="$(command head -n 1 /etc/issue | command sed 's/\\.//g')"
        if [ -z "${NVM_LOCAL_OS_VERSION}" ] && [ -r "/etc/os-release" ]; then
          # shellcheck disable=SC1091
          NVM_LOCAL_OS_VERSION="$(. /etc/os-release && echo "${NAME}" "${VERSION}")"
        fi
      fi
      if [ -n "${NVM_LOCAL_OS_VERSION}" ]; then
        nvm_err "OS version: ${NVM_LOCAL_OS_VERSION}"
      fi
      if nvm_has "curl"; then
        nvm_err "curl: $(nvm_command_info curl), $(command curl -V | command head -n 1)"
      else
        nvm_err "curl: not found"
      fi
      if nvm_has "wget"; then
        nvm_err "wget: $(nvm_command_info wget), $(command wget -V | command head -n 1)"
      else
        nvm_err "wget: not found"
      fi

      local NVM_LOCAL_TEST_TOOLS
      local NVM_LOCAL_ADD_TEST_TOOLS
      NVM_LOCAL_TEST_TOOLS="git grep awk"
      NVM_LOCAL_ADD_TEST_TOOLS="sed cut basename rm mkdir xargs"
      if [ "darwin" != "$(nvm_get_os)" ] && [ "freebsd" != "$(nvm_get_os)" ]; then
        NVM_LOCAL_TEST_TOOLS="${NVM_LOCAL_TEST_TOOLS} ${NVM_LOCAL_ADD_TEST_TOOLS}"
      else
        for NVM_LOCAL_TOOL in ${NVM_LOCAL_ADD_TEST_TOOLS} ; do
          if nvm_has "${NVM_LOCAL_TOOL}"; then
            nvm_err "${NVM_LOCAL_TOOL}: $(nvm_command_info "${NVM_LOCAL_TOOL}")"
          else
            nvm_err "${NVM_LOCAL_TOOL}: not found"
          fi
        done
      fi
      for NVM_LOCAL_TOOL in ${NVM_LOCAL_TEST_TOOLS} ; do
        local NVM_LOCAL_TOOL_VERSION
        if nvm_has "${NVM_LOCAL_TOOL}"; then
          if command ls -l "$(nvm_command_info "${NVM_LOCAL_TOOL}" | command awk '{print $1}')" | command grep -q busybox; then
            NVM_LOCAL_TOOL_VERSION="$(command "${NVM_LOCAL_TOOL}" --help 2>&1 | command head -n 1)"
          else
            NVM_LOCAL_TOOL_VERSION="$(command "${NVM_LOCAL_TOOL}" --version 2>&1 | command head -n 1)"
          fi
          nvm_err "${NVM_LOCAL_TOOL}: $(nvm_command_info "${NVM_LOCAL_TOOL}"), ${NVM_LOCAL_TOOL_VERSION}"
        else
          nvm_err "${NVM_LOCAL_TOOL}: not found"
        fi
        unset NVM_LOCAL_TOOL_VERSION
      done
      unset NVM_LOCAL_TEST_TOOLS
      unset NVM_LOCAL_ADD_TEST_TOOLS

      local NVM_LOCAL_DEBUG_OUTPUT
      for NVM_DEBUG_COMMAND in 'nvm current' 'which node' 'which iojs' 'which npm' 'npm config get prefix' 'npm root -g'; do
        NVM_LOCAL_DEBUG_OUTPUT="$(${NVM_DEBUG_COMMAND} 2>&1)"
        nvm_err "${NVM_DEBUG_COMMAND}: $(nvm_sanitize_path "${NVM_LOCAL_DEBUG_OUTPUT}")"
      done
      return 42
    ;;

    "install" | "i")
      local NVM_LOCAL_VERSION_NOT_PROVIDED
      NVM_LOCAL_VERSION_NOT_PROVIDED=0
      local NVM_LOCAL_OS
      NVM_LOCAL_OS="$(nvm_get_os)"

      if ! nvm_has "curl" && ! nvm_has "wget"; then
        nvm_err 'nvm needs curl or wget to proceed.'
        return 1
      fi

      if [ $# -lt 1 ]; then
        NVM_LOCAL_VERSION_NOT_PROVIDED=1
      fi

      local NVM_LOCAL_NOBINARY
      local NVM_LOCAL_NOSOURCE
      local NVM_LOCAL_NOPROGRESS
      NVM_LOCAL_NOBINARY=0
      NVM_LOCAL_NOPROGRESS=0
      NVM_LOCAL_NOSOURCE=0
      local NVM_LOCAL_LTS
      local NVM_LOCAL_ALIAS
      local NVM_LOCAL_UPGRADE_NPM
      NVM_LOCAL_UPGRADE_NPM=0

      local NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM
      local NVM_LOCAL_REINSTALL_PACKAGES_FROM
      local NVM_LOCAL_SKIP_DEFAULT_PACKAGES
      local NVM_LOCAL_DEFAULT_PACKAGES

      while [ $# -ne 0 ]; do
        case "$1" in
          ---*)
            nvm_err 'arguments with `---` are not supported - this is likely a typo'
            return 55;
          ;;
          -s)
            shift # consume "-s"
            NVM_LOCAL_NOBINARY=1
            if [ ${NVM_LOCAL_NOSOURCE} -eq 1 ]; then
                nvm err '-s and -b cannot be set together since they would skip install from both binary and source'
                return 6
            fi
          ;;
          -b)
            shift # consume "-b"
            NVM_LOCAL_NOSOURCE=1
            if [ ${NVM_LOCAL_NOBINARY} -eq 1 ]; then
                nvm err '-s and -b cannot be set together since they would skip install from both binary and source'
                return 6
            fi
          ;;
          -j)
            shift # consume "-j"
            nvm_get_make_jobs "$1"
            shift # consume job count
          ;;
          --no-progress)
            NVM_LOCAL_NOPROGRESS=1
            shift
          ;;
          --lts)
            NVM_LOCAL_LTS='*'
            shift
          ;;
          --lts=*)
            NVM_LOCAL_LTS="${1##--lts=}"
            shift
          ;;
          --latest-npm)
            NVM_LOCAL_UPGRADE_NPM=1
            shift
          ;;
          --default)
            if [ -n "${NVM_LOCAL_ALIAS-}" ]; then
              nvm_err '--default and --alias are mutually exclusive, and may not be provided more than once'
              return 6
            fi
            NVM_LOCAL_ALIAS='default'
            shift
          ;;
          --alias=*)
            if [ -n "${NVM_LOCAL_ALIAS-}" ]; then
              nvm_err '--default and --alias are mutually exclusive, and may not be provided more than once'
              return 6
            fi
            NVM_LOCAL_ALIAS="${1##--alias=}"
            shift
          ;;
          --reinstall-packages-from=*)
            if [ -n "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM-}" ]; then
              nvm_err '--reinstall-packages-from may not be provided more than once'
              return 6
            fi
            NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM="$(nvm_echo "$1" | command cut -c 27-)"
            if [ -z "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}" ]; then
              nvm_err 'If --reinstall-packages-from is provided, it must point to an installed version of node.'
              return 6
            fi
            NVM_LOCAL_REINSTALL_PACKAGES_FROM="$(nvm_version "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}")" ||:
            shift
          ;;
          --copy-packages-from=*)
            if [ -n "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM-}" ]; then
              nvm_err '--reinstall-packages-from may not be provided more than once, or combined with `--copy-packages-from`'
              return 6
            fi
            NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM="$(nvm_echo "$1" | command cut -c 22-)"
            if [ -z "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}" ]; then
              nvm_err 'If --copy-packages-from is provided, it must point to an installed version of node.'
              return 6
            fi
            NVM_LOCAL_REINSTALL_PACKAGES_FROM="$(nvm_version "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}")" ||:
            shift
          ;;
          --reinstall-packages-from | --copy-packages-from)
            nvm_err "If ${1} is provided, it must point to an installed version of node using \`=\`."
            return 6
          ;;
          --skip-default-packages)
            NVM_LOCAL_SKIP_DEFAULT_PACKAGES=true
            shift
          ;;
          *)
            break # stop parsing args
          ;;
        esac
      done

      local NVM_LOCAL_PROVIDED_VERSION
      NVM_LOCAL_PROVIDED_VERSION="${1-}"

      if [ -z "${NVM_LOCAL_PROVIDED_VERSION}" ]; then
        if [ "_${NVM_LOCAL_LTS-}" = '_*' ]; then
          nvm_echo 'Installing latest LTS version.'
          if [ $# -gt 0 ]; then
            shift
          fi
        elif [ "_${NVM_LOCAL_LTS-}" != '_' ]; then
          nvm_echo "Installing with latest version of LTS line: ${NVM_LOCAL_LTS}"
          if [ $# -gt 0 ]; then
            shift
          fi
        else
          nvm_rc_version
          if [ ${NVM_LOCAL_VERSION_NOT_PROVIDED} -eq 1 ] && [ -z "${NVM_RC_VERSION}" ]; then
            unset NVM_RC_VERSION
            >&2 nvm --help
            return 127
          fi
          NVM_LOCAL_PROVIDED_VERSION="${NVM_RC_VERSION}"
          unset NVM_RC_VERSION
        fi
      elif [ $# -gt 0 ]; then
        shift
      fi

      case "${NVM_LOCAL_PROVIDED_VERSION}" in
        'lts/*')
          NVM_LOCAL_LTS='*'
          NVM_LOCAL_PROVIDED_VERSION=''
        ;;
        lts/*)
          NVM_LOCAL_LTS="${NVM_LOCAL_PROVIDED_VERSION##lts/}"
          NVM_LOCAL_PROVIDED_VERSION=''
        ;;
      esac

      NVM_LOCAL_VERSION="$(NVM_VERSION_ONLY=true NVM_LTS="${NVM_LOCAL_LTS-}" nvm_remote_version "${NVM_LOCAL_PROVIDED_VERSION}")"

      if [ "${NVM_LOCAL_VERSION}" = 'N/A' ]; then
        local NVM_LOCAL_LTS_MSG
        local NVM_LOCAL_REMOTE_CMD
        if [ "${NVM_LOCAL_LTS-}" = '*' ]; then
          NVM_LOCAL_LTS_MSG='(with LTS filter) '
          NVM_LOCAL_REMOTE_CMD='nvm ls-remote --lts'
        elif [ -n "${NVM_LOCAL_LTS-}" ]; then
          NVM_LOCAL_LTS_MSG="(with LTS filter '${NVM_LOCAL_LTS}') "
          NVM_LOCAL_REMOTE_CMD="nvm ls-remote --lts=${NVM_LOCAL_LTS}"
        else
          NVM_LOCAL_REMOTE_CMD='nvm ls-remote'
        fi
        nvm_err "Version '${NVM_LOCAL_PROVIDED_VERSION}' ${NVM_LOCAL_LTS_MSG-}not found - try \`${NVM_LOCAL_REMOTE_CMD}\` to browse available versions."
        return 3
      fi

      NVM_LOCAL_ADDITIONAL_PARAMETERS=''

      while [ $# -ne 0 ]; do
        case "$1" in
          --reinstall-packages-from=*)
            if [ -n "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM-}" ]; then
              nvm_err '--reinstall-packages-from may not be provided more than once'
              return 6
            fi
            NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM="$(nvm_echo "$1" | command cut -c 27-)"
            if [ -z "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}" ]; then
              nvm_err 'If --reinstall-packages-from is provided, it must point to an installed version of node.'
              return 6
            fi
            NVM_LOCAL_REINSTALL_PACKAGES_FROM="$(nvm_version "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}")" ||:
          ;;
          --copy-packages-from=*)
            if [ -n "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM-}" ]; then
              nvm_err '--reinstall-packages-from may not be provided more than once, or combined with `--copy-packages-from`'
              return 6
            fi
            NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM="$(nvm_echo "$1" | command cut -c 22-)"
            if [ -z "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}" ]; then
              nvm_err 'If --copy-packages-from is provided, it must point to an installed version of node.'
              return 6
            fi
            NVM_LOCAL_REINSTALL_PACKAGES_FROM="$(nvm_version "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}")" ||:
          ;;
          --reinstall-packages-from | --copy-packages-from)
            nvm_err "If ${1} is provided, it must point to an installed version of node using \`=\`."
            return 6
          ;;
          --skip-default-packages)
            NVM_LOCAL_SKIP_DEFAULT_PACKAGES=true
          ;;
          *)
            NVM_LOCAL_ADDITIONAL_PARAMETERS="${NVM_LOCAL_ADDITIONAL_PARAMETERS} $1"
          ;;
        esac
        shift
      done

      local NVM_LOCAL_EXIT_CODE
      if [ -z "${NVM_LOCAL_SKIP_DEFAULT_PACKAGES-}" ]; then
        NVM_LOCAL_DEFAULT_PACKAGES="$(nvm_get_default_packages)"
        NVM_LOCAL_EXIT_CODE=$?
        if [ ${NVM_LOCAL_EXIT_CODE} -ne 0 ]; then
          return ${NVM_LOCAL_EXIT_CODE}
        fi
      fi

      if [ -n "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM-}" ] && [ "$(nvm_ensure_version_prefix "${NVM_LOCAL_PROVIDED_REINSTALL_PACKAGES_FROM}")" = "${NVM_LOCAL_VERSION}" ]; then
        nvm_err "You can't reinstall global packages from the same version of node you're installing."
        return 4
      elif [ "${NVM_LOCAL_REINSTALL_PACKAGES_FROM-}" = 'N/A' ]; then
        nvm_err "If --reinstall-packages-from is provided, it must point to an installed version of node."
        return 5
      fi

      local NVM_LOCAL_FLAVOR
      if nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
        NVM_LOCAL_FLAVOR="$(nvm_iojs_prefix)"
      else
        NVM_LOCAL_FLAVOR="$(nvm_node_prefix)"
      fi

      if nvm_is_version_installed "${NVM_LOCAL_VERSION}"; then
        nvm_err "${NVM_LOCAL_VERSION} is already installed."
        if nvm use "${NVM_LOCAL_VERSION}"; then
          if [ "${NVM_LOCAL_UPGRADE_NPM}" = 1 ]; then
            nvm install-latest-npm
          fi
          if [ -z "${NVM_LOCAL_SKIP_DEFAULT_PACKAGES-}" ] && [ -n "${NVM_LOCAL_DEFAULT_PACKAGES-}" ]; then
            nvm_install_default_packages "${NVM_LOCAL_DEFAULT_PACKAGES}"
          fi
          if [ -n "${NVM_LOCAL_REINSTALL_PACKAGES_FROM-}" ] && [ "_${NVM_LOCAL_REINSTALL_PACKAGES_FROM}" != "_N/A" ]; then
            nvm reinstall-packages "${NVM_LOCAL_REINSTALL_PACKAGES_FROM}"
          fi
        fi
        if [ -n "${NVM_LOCAL_LTS-}" ]; then
          NVM_LOCAL_LTS="$(echo "${NVM_LOCAL_LTS}" | tr '[:upper:]' '[:lower:]')"
          nvm_ensure_default_set "lts/${NVM_LOCAL_LTS}"
        else
          nvm_ensure_default_set "${NVM_LOCAL_PROVIDED_VERSION}"
        fi

        if [ -n "${NVM_LOCAL_ALIAS-}" ]; then
          nvm alias "${NVM_LOCAL_ALIAS}" "${NVM_LOCAL_PROVIDED_VERSION}"
        fi

        return $?
      fi

      NVM_LOCAL_EXIT_CODE=-1
      if [ -n "${NVM_INSTALL_THIRD_PARTY_HOOK-}" ]; then
        nvm_err '** ${NVM_INSTALL_THIRD_PARTY_HOOK} env var set; dispatching to third-party installation method **'
        local NVM_LOCAL_METHOD_PREFERENCE
        NVM_LOCAL_METHOD_PREFERENCE='binary'
        if [ ${NVM_LOCAL_NOBINARY} -eq 1 ]; then
          NVM_LOCAL_METHOD_PREFERENCE='source'
        fi
        local NVM_LOCAL_VERSION_PATH
        NVM_LOCAL_VERSION_PATH="$(nvm_version_path "${NVM_LOCAL_VERSION}")"
        "${NVM_INSTALL_THIRD_PARTY_HOOK}" "${NVM_LOCAL_VERSION}" "${NVM_LOCAL_FLAVOR}" std "${NVM_LOCAL_METHOD_PREFERENCE}" "${NVM_LOCAL_VERSION_PATH}" || {
          NVM_LOCAL_EXIT_CODE=$?
          nvm_err '*** Third-party ${NVM_INSTALL_THIRD_PARTY_HOOK} env var failed to install! ***'
          return ${NVM_LOCAL_EXIT_CODE}
        }
        if ! nvm_is_version_installed "${NVM_LOCAL_VERSION}"; then
          nvm_err '*** Third-party ${NVM_INSTALL_THIRD_PARTY_HOOK} env var claimed to succeed, but failed to install! ***'
          return 33
        fi
        NVM_LOCAL_EXIT_CODE=0
      else

        if [ "_${NVM_LOCAL_OS}" = "_freebsd" ]; then
          # node.js and io.js do not have a FreeBSD binary
          NVM_LOCAL_NOBINARY=1
          nvm_err "Currently, there is no binary for FreeBSD"
        elif [ "_${NVM_LOCAL_OS}" = "_openbsd" ]; then
          # node.js and io.js do not have a OpenBSD binary
          NVM_LOCAL_NOBINARY=1
          nvm_err "Currently, there is no binary for OpenBSD"
        elif [ "_${NVM_LOCAL_OS}" = "_sunos" ]; then
          # Not all node/io.js versions have a Solaris binary
          if ! nvm_has_solaris_binary "${NVM_LOCAL_VERSION}"; then
            NVM_LOCAL_NOBINARY=1
            nvm_err "Currently, there is no binary of version ${NVM_LOCAL_VERSION} for SunOS"
          fi
        fi

        # skip binary install if "NVM_LOCAL_NOBINARY" option specified.
        if [ ${NVM_LOCAL_NOBINARY} -ne 1 ] && nvm_binary_available "${NVM_LOCAL_VERSION}"; then
          NVM_NO_PROGRESS="${NVM_NO_PROGRESS:-${NVM_LOCAL_NOPROGRESS}}" nvm_install_binary "${NVM_LOCAL_FLAVOR}" std "${NVM_LOCAL_VERSION}" "${NVM_LOCAL_NOSOURCE}"
          NVM_LOCAL_EXIT_CODE=$?
        fi
        if [ ${NVM_LOCAL_EXIT_CODE} -ne 0 ]; then
          if [ -z "${NVM_LOCAL_MAKE_JOBS-}" ]; then
            nvm_get_make_jobs
          fi

          if [ "_${NVM_LOCAL_OS}" = "_win" ]; then
            nvm_err 'Installing from source on non-WSL Windows is not supported'
            NVM_LOCAL_EXIT_CODE=87
          else
            NVM_NO_PROGRESS="${NVM_NO_PROGRESS:-${NVM_LOCAL_NOPROGRESS}}" nvm_install_source "${NVM_LOCAL_FLAVOR}" std "${NVM_LOCAL_VERSION}" "${NVM_LOCAL_MAKE_JOBS}" "${NVM_LOCAL_ADDITIONAL_PARAMETERS}"
            NVM_LOCAL_EXIT_CODE=$?
          fi
        fi

      fi

      if [ ${NVM_LOCAL_EXIT_CODE} -eq 0 ] && nvm_use_if_needed "${NVM_LOCAL_VERSION}" && nvm_install_npm_if_needed "${NVM_LOCAL_VERSION}"; then
        if [ -n "${NVM_LOCAL_LTS-}" ]; then
          nvm_ensure_default_set "lts/${NVM_LOCAL_LTS}"
        else
          nvm_ensure_default_set "${NVM_LOCAL_PROVIDED_VERSION}"
        fi
        if [ "${NVM_LOCAL_UPGRADE_NPM}" = 1 ]; then
          nvm install-latest-npm
          NVM_LOCAL_EXIT_CODE=$?
        fi
        if [ -z "${NVM_LOCAL_SKIP_DEFAULT_PACKAGES-}" ] && [ -n "${NVM_LOCAL_DEFAULT_PACKAGES-}" ]; then
          nvm_install_default_packages "${NVM_LOCAL_DEFAULT_PACKAGES}"
        fi
        if [ -n "${NVM_LOCAL_REINSTALL_PACKAGES_FROM-}" ] && [ "_${NVM_LOCAL_REINSTALL_PACKAGES_FROM}" != "_N/A" ]; then
          nvm reinstall-packages "${NVM_LOCAL_REINSTALL_PACKAGES_FROM}"
          NVM_LOCAL_EXIT_CODE=$?
        fi
      else
        NVM_LOCAL_EXIT_CODE=$?
      fi
      return ${NVM_LOCAL_EXIT_CODE}
    ;;
    "uninstall")
      if [ $# -ne 1 ]; then
        >&2 nvm --help
        return 127
      fi

      local NVM_LOCAL_PATTERN
      NVM_LOCAL_PATTERN="${1-}"
      case "${NVM_LOCAL_PATTERN-}" in
        --) ;;
        --lts | 'lts/*')
          NVM_LOCAL_VERSION="$(nvm_match_version "lts/*")"
        ;;
        lts/*)
          NVM_LOCAL_VERSION="$(nvm_match_version "lts/${NVM_LOCAL_PATTERN##lts/}")"
        ;;
        --lts=*)
          NVM_LOCAL_VERSION="$(nvm_match_version "lts/${NVM_LOCAL_PATTERN##--lts=}")"
        ;;
        *)
          NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_PATTERN}")"
        ;;
      esac

      if [ "_${NVM_LOCAL_VERSION}" = "_$(nvm_ls_current)" ]; then
        if nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
          nvm_err "nvm: Cannot uninstall currently-active io.js version, ${NVM_LOCAL_VERSION} (inferred from ${NVM_LOCAL_PATTERN})."
        else
          nvm_err "nvm: Cannot uninstall currently-active node version, ${NVM_LOCAL_VERSION} (inferred from ${NVM_LOCAL_PATTERN})."
        fi
        return 1
      fi

      if ! nvm_is_version_installed "${NVM_LOCAL_VERSION}"; then
        nvm_err "${NVM_LOCAL_VERSION} version is not installed..."
        return
      fi

      local NVM_LOCAL_SLUG_BINARY
      local NVM_LOCAL_SLUG_SOURCE
      if nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
        NVM_LOCAL_SLUG_BINARY="$(nvm_get_download_slug iojs binary std "${NVM_LOCAL_VERSION}")"
        NVM_LOCAL_SLUG_SOURCE="$(nvm_get_download_slug iojs source std "${NVM_LOCAL_VERSION}")"
      else
        NVM_LOCAL_SLUG_BINARY="$(nvm_get_download_slug node binary std "${NVM_LOCAL_VERSION}")"
        NVM_LOCAL_SLUG_SOURCE="$(nvm_get_download_slug node source std "${NVM_LOCAL_VERSION}")"
      fi

      local NVM_LOCAL_SUCCESS_MSG
      if nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
        NVM_LOCAL_SUCCESS_MSG="Uninstalled io.js $(nvm_strip_iojs_prefix "${NVM_LOCAL_VERSION}")"
      else
        NVM_LOCAL_SUCCESS_MSG="Uninstalled node ${NVM_LOCAL_VERSION}"
      fi

      local NVM_LOCAL_VERSION_PATH
      NVM_LOCAL_VERSION_PATH="$(nvm_version_path "${NVM_LOCAL_VERSION}")"
      if ! nvm_check_file_permissions "${NVM_LOCAL_VERSION_PATH}"; then
        nvm_err 'Cannot uninstall, incorrect permissions on installation folder.'
        nvm_err 'This is usually caused by running `npm install -g` as root. Run the following commands as root to fix the permissions and then try again.'
        nvm_err
        nvm_err "  chown -R $(whoami) \"$(nvm_sanitize_path "${NVM_LOCAL_VERSION_PATH}")\""
        nvm_err "  chmod -R u+w \"$(nvm_sanitize_path "${NVM_LOCAL_VERSION_PATH}")\""
        return 1
      fi

      # Delete all files related to target version.
      local NVM_LOCAL_CACHE_DIR
      NVM_LOCAL_CACHE_DIR="$(nvm_cache_dir)"
      command rm -rf \
        "${NVM_LOCAL_CACHE_DIR}/bin/${NVM_LOCAL_SLUG_BINARY}/files" \
        "${NVM_LOCAL_CACHE_DIR}/src/${NVM_LOCAL_SLUG_SOURCE}/files" \
        "${NVM_LOCAL_VERSION_PATH}" 2>/dev/null
      nvm_echo "${NVM_LOCAL_SUCCESS_MSG}"

      # rm any aliases that point to uninstalled version.
      for NVM_LOCAL_FOR_ALIAS in $(nvm_grep -l "${NVM_LOCAL_VERSION}" "$(nvm_alias_path)/*" 2>/dev/null); do
        nvm unalias "$(command basename "${NVM_LOCAL_FOR_ALIAS}")"
      done
    ;;
    "deactivate")
      local NVM_LOCAL_SILENT
      while [ $# -ne 0 ]; do
        case "${1}" in
          --silent) NVM_LOCAL_SILENT=1 ;;
          --) ;;
        esac
        shift
      done
      local NVM_LOCAL_NEWPATH
      NVM_LOCAL_NEWPATH="$(nvm_strip_path "${PATH}" "/bin")"
      if [ "_${PATH}" = "_${NVM_LOCAL_NEWPATH}" ]; then
        if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
          nvm_err "Could not find ${NVM_DIR}/*/bin in \${PATH}"
        fi
      else
        export PATH="${NVM_LOCAL_NEWPATH}"
        hash -r
        if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
          nvm_echo "${NVM_DIR}/*/bin removed from \${PATH}"
        fi
      fi

      if [ -n "${MANPATH-}" ]; then
        NVM_LOCAL_NEWPATH="$(nvm_strip_path "${MANPATH}" "/share/man")"
        if [ "_${MANPATH}" = "_${NVM_LOCAL_NEWPATH}" ]; then
          if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
            nvm_err "Could not find ${NVM_DIR}/*/share/man in \${MANPATH}"
          fi
        else
          export MANPATH="${NVM_LOCAL_NEWPATH}"
          if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
            nvm_echo "${NVM_DIR}/*/share/man removed from \${MANPATH}"
          fi
        fi
      fi

      if [ -n "${NODE_PATH-}" ]; then
        NVM_LOCAL_NEWPATH="$(nvm_strip_path "${NODE_PATH}" "/lib/node_modules")"
        if [ "_${NODE_PATH}" != "_${NVM_LOCAL_NEWPATH}" ]; then
          export NODE_PATH="${NVM_LOCAL_NEWPATH}"
          if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
            nvm_echo "${NVM_DIR}/*/lib/node_modules removed from \${NODE_PATH}"
          fi
        fi
      fi
      unset NVM_BIN
      unset NVM_INC
    ;;
    "use")
      local NVM_LOCAL_PROVIDED_VERSION
      local NVM_LOCAL_SILENT
      local NVM_LOCAL_SILENT_ARG
      local NVM_LOCAL_DELETE_PREFIX
      NVM_LOCAL_DELETE_PREFIX=0
      local NVM_LOCAL_LTS

      while [ $# -ne 0 ]; do
        case "$1" in
          --silent)
            NVM_LOCAL_SILENT=1
            NVM_LOCAL_SILENT_ARG='--silent'
          ;;
          --delete-prefix) NVM_LOCAL_DELETE_PREFIX=1 ;;
          --) ;;
          --lts) NVM_LOCAL_LTS='*' ;;
          --lts=*) NVM_LOCAL_LTS="${1##--lts=}" ;;
          --*) ;;
          *)
            if [ -n "${1-}" ]; then
              NVM_LOCAL_PROVIDED_VERSION="$1"
            fi
          ;;
        esac
        shift
      done

      if [ -n "${NVM_LOCAL_LTS-}" ]; then
        NVM_LOCAL_VERSION="$(nvm_match_version "lts/${NVM_LOCAL_LTS:-*}")"
      elif [ -z "${NVM_LOCAL_PROVIDED_VERSION-}" ]; then
        NVM_LOCAL_SILENT="${NVM_LOCAL_SILENT:-0}" nvm_rc_version
        if [ -n "${NVM_RC_VERSION-}" ]; then
          NVM_LOCAL_PROVIDED_VERSION="${NVM_RC_VERSION}"
          NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_PROVIDED_VERSION}")"
        fi
        unset NVM_RC_VERSION
        if [ -z "${NVM_LOCAL_VERSION}" ]; then
          nvm_err 'Please see `nvm --help` or https://github.com/nvm-sh/nvm#nvmrc for more information.'
          return 127
        fi
      else
        NVM_LOCAL_VERSION="$(nvm_match_version "${NVM_LOCAL_PROVIDED_VERSION}")"
      fi

      if [ -z "${NVM_LOCAL_VERSION}" ]; then
        >&2 nvm --help
        return 127
      fi

      if [ "_${NVM_LOCAL_VERSION}" = '_system' ]; then
        if nvm_has_system_node && nvm deactivate "${NVM_LOCAL_SILENT_ARG-}" >/dev/null 2>&1; then
          if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
            nvm_echo "Now using system version of node: $(node -v 2>/dev/null)$(nvm_print_npm_version)"
          fi
          return
        elif nvm_has_system_iojs && nvm deactivate "${NVM_LOCAL_SILENT_ARG-}" >/dev/null 2>&1; then
          if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
            nvm_echo "Now using system version of io.js: $(iojs --version 2>/dev/null)$(nvm_print_npm_version)"
          fi
          return
        elif [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
          nvm_err 'System version of node not found.'
        fi
        return 127
      elif [ "_${NVM_LOCAL_VERSION}" = "_∞" ]; then
        if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
          nvm_err "The alias \"${NVM_LOCAL_PROVIDED_VERSION}\" leads to an infinite loop. Aborting."
        fi
        return 8
      fi
      if [ "${NVM_LOCAL_VERSION}" = 'N/A' ]; then
        if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
          nvm_err "N/A: version \"${NVM_LOCAL_PROVIDED_VERSION} -> ${NVM_LOCAL_VERSION}\" is not yet installed."
          nvm_err ""
          nvm_err "You need to run \"nvm install ${NVM_LOCAL_PROVIDED_VERSION}\" to install it before using it."
        fi
        return 3
      # This nvm_ensure_version_installed call can be a performance bottleneck
      # on shell startup. Perhaps we can optimize it away or make it faster.
      elif ! nvm_ensure_version_installed "${NVM_LOCAL_VERSION}"; then
        return $?
      fi

      local NVM_LOCAL_VERSION_DIR
      NVM_LOCAL_VERSION_DIR="$(nvm_version_path "${NVM_LOCAL_VERSION}")"

      # Change current version
      PATH="$(nvm_change_path "${PATH}" "/bin" "${NVM_LOCAL_VERSION_DIR}")"
      if nvm_has manpath; then
        if [ -z "${MANPATH-}" ]; then
          local MANPATH
          MANPATH=$(manpath)
        fi
        # Change current version
        MANPATH="$(nvm_change_path "${MANPATH}" "/share/man" "${NVM_LOCAL_VERSION_DIR}")"
        export MANPATH
      fi
      export PATH
      hash -r
      export NVM_BIN="${NVM_LOCAL_VERSION_DIR}/bin"
      export NVM_INC="${NVM_LOCAL_VERSION_DIR}/include/node"
      if [ "${NVM_SYMLINK_CURRENT-}" = true ]; then
        command rm -f "${NVM_DIR}/current" && ln -s "${NVM_LOCAL_VERSION_DIR}" "${NVM_DIR}/current"
      fi
      local NVM_LOCAL_USE_OUTPUT
      NVM_LOCAL_USE_OUTPUT=''
      if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
        if nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
          NVM_LOCAL_USE_OUTPUT="Now using io.js $(nvm_strip_iojs_prefix "${NVM_LOCAL_VERSION}")$(nvm_print_npm_version)"
        else
          NVM_LOCAL_USE_OUTPUT="Now using node ${NVM_LOCAL_VERSION}$(nvm_print_npm_version)"
        fi
      fi
      if [ "_${NVM_LOCAL_VERSION}" != "_system" ]; then
        local NVM_LOCAL_USE_CMD
        NVM_LOCAL_USE_CMD="nvm use --delete-prefix"
        if [ -n "${NVM_LOCAL_PROVIDED_VERSION}" ]; then
          NVM_LOCAL_USE_CMD="${NVM_LOCAL_USE_CMD} ${NVM_LOCAL_VERSION}"
        fi
        if [ "${NVM_LOCAL_SILENT:-0}" -eq 1 ]; then
          NVM_LOCAL_USE_CMD="${NVM_LOCAL_USE_CMD} --silent"
        fi
        if ! nvm_die_on_prefix "${NVM_LOCAL_DELETE_PREFIX}" "${NVM_LOCAL_USE_CMD}" "${NVM_LOCAL_VERSION_DIR}"; then
          return 11
        fi
      fi
      if [ -n "${NVM_LOCAL_USE_OUTPUT-}" ] && [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
        nvm_echo "${NVM_LOCAL_USE_OUTPUT}"
      fi
    ;;
    "run")
      local NVM_LOCAL_PROVIDED_VERSION
      local NVM_LOCAL_HAS_CHECKED_NVMRC
      NVM_LOCAL_HAS_CHECKED_NVMRC=0
      # run given version of node

      local NVM_LOCAL_SILENT
      local NVM_LOCAL_SILENT_ARG
      local NVM_LOCAL_LTS
      while [ $# -gt 0 ]; do
        case "$1" in
          --silent)
            NVM_LOCAL_SILENT=1
            NVM_LOCAL_SILENT_ARG='--silent'
            shift
          ;;
          --lts) NVM_LOCAL_LTS='*' ; shift ;;
          --lts=*) NVM_LOCAL_LTS="${1##--lts=}" ; shift ;;
          *)
            if [ -n "$1" ]; then
              break
            else
              shift
            fi
          ;; # stop processing arguments
        esac
      done

      if [ $# -lt 1 ] && [ -z "${NVM_LOCAL_LTS-}" ]; then
        NVM_LOCAL_SILENT="${NVM_LOCAL_SILENT:-0}" nvm_rc_version && NVM_LOCAL_HAS_CHECKED_NVMRC=1
        if [ -n "${NVM_RC_VERSION-}" ]; then
          NVM_LOCAL_VERSION="$(nvm_version "${NVM_RC_VERSION-}")" ||:
        fi
        unset NVM_RC_VERSION
        if [ "${NVM_LOCAL_VERSION:-N/A}" = 'N/A' ]; then
          >&2 nvm --help
          return 127
        fi
      fi

      if [ -z "${NVM_LOCAL_LTS-}" ]; then
        NVM_LOCAL_PROVIDED_VERSION="$1"
        if [ -n "${NVM_LOCAL_PROVIDED_VERSION}" ]; then
          NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_PROVIDED_VERSION}")" ||:
          if [ "_${NVM_LOCAL_VERSION:-N/A}" = '_N/A' ] && ! nvm_is_valid_version "${NVM_LOCAL_PROVIDED_VERSION}"; then
            NVM_LOCAL_PROVIDED_VERSION=''
            if [ ${NVM_LOCAL_HAS_CHECKED_NVMRC} -ne 1 ]; then
              NVM_LOCAL_SILENT="${NVM_LOCAL_SILENT:-0}" nvm_rc_version && NVM_LOCAL_HAS_CHECKED_NVMRC=1
            fi
            NVM_LOCAL_VERSION="$(nvm_version "${NVM_RC_VERSION}")" ||:
            unset NVM_RC_VERSION
          else
            shift
          fi
        fi
      fi

      local NVM_LOCAL_IOJS
      if nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
        NVM_LOCAL_IOJS=true
      fi

      local NVM_LOCAL_EXIT_CODE

      nvm_is_zsh && setopt local_options shwordsplit
      local NVM_LOCAL_LTS_ARG
      if [ -n "${NVM_LOCAL_LTS-}" ]; then
        NVM_LOCAL_LTS_ARG="--lts=${NVM_LOCAL_LTS-}"
        NVM_LOCAL_VERSION=''
      fi
      if [ "_${NVM_LOCAL_VERSION}" = "_N/A" ]; then
        nvm_ensure_version_installed "${NVM_LOCAL_PROVIDED_VERSION}"
      elif [ "${NVM_LOCAL_IOJS}" = true ]; then
        nvm exec "${NVM_LOCAL_SILENT_ARG-}" "${NVM_LOCAL_LTS_ARG-}" "${NVM_LOCAL_VERSION}" iojs "$@"
      else
        nvm exec "${NVM_LOCAL_SILENT_ARG-}" "${NVM_LOCAL_LTS_ARG-}" "${NVM_LOCAL_VERSION}" node "$@"
      fi
      NVM_LOCAL_EXIT_CODE="$?"
      return ${NVM_LOCAL_EXIT_CODE}
    ;;
    "exec")
      local NVM_LOCAL_SILENT
      local NVM_LOCAL_LTS
      while [ $# -gt 0 ]; do
        case "$1" in
          --silent) NVM_LOCAL_SILENT=1 ; shift ;;
          --lts) NVM_LOCAL_LTS='*' ; shift ;;
          --lts=*) NVM_LOCAL_LTS="${1##--lts=}" ; shift ;;
          --) break ;;
          --*)
            nvm_err "Unsupported option \"$1\"."
            return 55
          ;;
          *)
            if [ -n "$1" ]; then
              break
            else
              shift
            fi
          ;; # stop processing arguments
        esac
      done

      local NVM_LOCAL_PROVIDED_VERSION
      NVM_LOCAL_PROVIDED_VERSION="$1"
      if [ "${NVM_LOCAL_LTS-}" != '' ]; then
        NVM_LOCAL_PROVIDED_VERSION="lts/${NVM_LOCAL_LTS:-*}"
        NVM_LOCAL_VERSION="${NVM_LOCAL_PROVIDED_VERSION}"
      elif [ -n "${NVM_LOCAL_PROVIDED_VERSION}" ]; then
        NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_PROVIDED_VERSION}")" ||:
        if [ "_${NVM_LOCAL_VERSION}" = '_N/A' ] && ! nvm_is_valid_version "${NVM_LOCAL_PROVIDED_VERSION}"; then
          NVM_LOCAL_SILENT="${NVM_LOCAL_SILENT:-0}" nvm_rc_version && NVM_LOCAL_HAS_CHECKED_NVMRC=1
          NVM_LOCAL_PROVIDED_VERSION="${NVM_RC_VERSION}"
          unset NVM_RC_VERSION
          NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_PROVIDED_VERSION}")" ||:
        else
          shift
        fi
      fi

      local NVM_LOCAL_EXIT_CODE
      nvm_ensure_version_installed "${NVM_LOCAL_PROVIDED_VERSION}"
      NVM_LOCAL_EXIT_CODE=$?
      if [ "${NVM_LOCAL_EXIT_CODE}" != "0" ]; then
        return ${NVM_LOCAL_EXIT_CODE}
      fi

      if [ "${NVM_LOCAL_SILENT:-0}" -ne 1 ]; then
        if [ "${NVM_LOCAL_LTS-}" = '*' ]; then
          nvm_echo "Running node latest LTS -> $(nvm_version "${NVM_LOCAL_VERSION}")$(nvm use --silent "${NVM_LOCAL_VERSION}" && nvm_print_npm_version)"
        elif [ -n "${NVM_LOCAL_LTS-}" ]; then
          nvm_echo "Running node LTS \"${NVM_LOCAL_LTS-}\" -> $(nvm_version "${NVM_LOCAL_VERSION}")$(nvm use --silent "${NVM_LOCAL_VERSION}" && nvm_print_npm_version)"
        elif nvm_is_iojs_version "${NVM_LOCAL_VERSION}"; then
          nvm_echo "Running io.js $(nvm_strip_iojs_prefix "${NVM_LOCAL_VERSION}")$(nvm use --silent "${NVM_LOCAL_VERSION}" && nvm_print_npm_version)"
        else
          nvm_echo "Running node ${NVM_LOCAL_VERSION}$(nvm use --silent "${NVM_LOCAL_VERSION}" && nvm_print_npm_version)"
        fi
      fi
      NODE_VERSION="${NVM_LOCAL_VERSION}" "${NVM_DIR}/nvm-exec" "$@"
    ;;
    "ls" | "list")
      local NVM_LOCAL_PATTERN
      local NVM_LOCAL_NO_COLORS
      local NVM_LOCAL_NO_ALIAS

      while [ $# -gt 0 ]; do
        case "${1}" in
          --) ;;
          --no-colors) NVM_LOCAL_NO_COLORS="${1}" ;;
          --no-alias) NVM_LOCAL_NO_ALIAS="${1}" ;;
          --*)
            nvm_err "Unsupported option \"${1}\"."
            return 55
          ;;
          *)
            NVM_LOCAL_PATTERN="${NVM_LOCAL_PATTERN:-$1}"
          ;;
        esac
        shift
      done
      if [ -n "${NVM_LOCAL_PATTERN-}" ] && [ -n "${NVM_LOCAL_NO_ALIAS-}" ]; then
        nvm_err '`--no-alias` is not supported when a pattern is provided.'
        return 55
      fi
      local NVM_LOCAL_LS_OUTPUT
      local NVM_LOCAL_LS_EXIT_CODE
      NVM_LOCAL_LS_OUTPUT=$(nvm_ls "${NVM_LOCAL_PATTERN-}")
      NVM_LOCAL_LS_EXIT_CODE=$?
      NVM_LOCAL_NO_COLORS="${NVM_LOCAL_NO_COLORS-}" nvm_print_versions "${NVM_LOCAL_LS_OUTPUT}"
      if [ -z "${NVM_LOCAL_NO_ALIAS-}" ] && [ -z "${NVM_LOCAL_PATTERN-}" ]; then
        if [ -n "${NVM_LOCAL_NO_COLORS-}" ]; then
          nvm alias --no-colors
        else
          nvm alias
        fi
      fi
      return ${NVM_LOCAL_LS_EXIT_CODE}
    ;;
    "ls-remote" | "list-remote")
      local NVM_LOCAL_LTS
      local NVM_LOCAL_PATTERN
      local NVM_LOCAL_NO_COLORS

      while [ $# -gt 0 ]; do
        case "${1-}" in
          --) ;;
          --lts)
            NVM_LOCAL_LTS='*'
          ;;
          --lts=*)
            NVM_LOCAL_LTS="${1##--lts=}"
          ;;
          --no-colors) NVM_LOCAL_NO_COLORS="${1}" ;;
          --*)
            nvm_err "Unsupported option \"${1}\"."
            return 55
          ;;
          *)
            if [ -z "${NVM_LOCAL_PATTERN-}" ]; then
              NVM_LOCAL_PATTERN="${1-}"
              if [ -z "${NVM_LOCAL_LTS-}" ]; then
                case "${NVM_LOCAL_PATTERN}" in
                  'lts/*')
                    NVM_LOCAL_LTS='*'
                    NVM_LOCAL_PATTERN=''
                  ;;
                  lts/*)
                    NVM_LOCAL_LTS="${NVM_LOCAL_PATTERN##lts/}"
                    NVM_LOCAL_PATTERN=''
                  ;;
                esac
              fi
            fi
          ;;
        esac
        shift
      done

      local NVM_LOCAL_OUTPUT
      local NVM_LOCAL_EXIT_CODE
      NVM_LOCAL_OUTPUT="$(NVM_LOCAL_LTS="${NVM_LOCAL_LTS-}" nvm_remote_versions "${NVM_LOCAL_PATTERN}" &&:)"
      NVM_LOCAL_EXIT_CODE=$?
      if [ -n "${NVM_LOCAL_OUTPUT}" ]; then
        NVM_LOCAL_NO_COLORS="${NVM_LOCAL_NO_COLORS-}" nvm_print_versions "${NVM_LOCAL_OUTPUT}"
        return ${NVM_LOCAL_EXIT_CODE}
      fi
      NVM_LOCAL_NO_COLORS="${NVM_LOCAL_NO_COLORS-}" nvm_print_versions "N/A"
      return 3
    ;;
    "current")
      nvm_version current
    ;;
    "which")
      local NVM_LOCAL_SILENT
      local NVM_LOCAL_PROVIDED_VERSION
      while [ $# -ne 0 ]; do
        case "${1}" in
          --silent) NVM_LOCAL_SILENT=1 ;;
          --) ;;
          *) NVM_LOCAL_PROVIDED_VERSION="${1-}" ;;
        esac
        shift
      done
      if [ -z "${NVM_LOCAL_PROVIDED_VERSION-}" ]; then
        NVM_LOCAL_SILENT="${NVM_LOCAL_SILENT:-0}" nvm_rc_version
        if [ -n "${NVM_RC_VERSION}" ]; then
          NVM_LOCAL_PROVIDED_VERSION="${NVM_RC_VERSION}"
          NVM_LOCAL_VERSION=$(nvm_version "${NVM_RC_VERSION}") ||:
        fi
        unset NVM_RC_VERSION
      elif [ "${NVM_LOCAL_PROVIDED_VERSION}" != 'system' ]; then
        NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_PROVIDED_VERSION}")" ||:
      else
        NVM_LOCAL_VERSION="${NVM_LOCAL_PROVIDED_VERSION-}"
      fi
      if [ -z "${NVM_LOCAL_VERSION}" ]; then
        >&2 nvm --help
        return 127
      fi

      if [ "_${NVM_LOCAL_VERSION}" = '_system' ]; then
        if nvm_has_system_iojs >/dev/null 2>&1 || nvm_has_system_node >/dev/null 2>&1; then
          local NVM_LOCAL_BIN
          NVM_LOCAL_BIN="$(nvm use system >/dev/null 2>&1 && command which node)"
          if [ -n "${NVM_LOCAL_BIN}" ]; then
            nvm_echo "${NVM_LOCAL_BIN}"
            return
          fi
          return 1
        fi
        nvm_err 'System version of node not found.'
        return 127
      elif [ "${NVM_LOCAL_VERSION}" = '∞' ]; then
        nvm_err "The alias \"${2}\" leads to an infinite loop. Aborting."
        return 8
      fi

      local NVM_LOCAL_EXIT_CODE
      nvm_ensure_version_installed "${NVM_LOCAL_PROVIDED_VERSION}"
      NVM_LOCAL_EXIT_CODE=$?
      if [ "${NVM_LOCAL_EXIT_CODE}" != "0" ]; then
        return ${NVM_LOCAL_EXIT_CODE}
      fi
      local NVM_LOCAL_VERSION_DIR
      NVM_LOCAL_VERSION_DIR="$(nvm_version_path "${NVM_LOCAL_VERSION}")"
      nvm_echo "${NVM_LOCAL_VERSION_DIR}/bin/node"
    ;;
    "alias")
      local NVM_LOCAL_ALIAS_DIR
      NVM_LOCAL_ALIAS_DIR="$(nvm_alias_path)"
      local NVM_LOCAL_CURRENT
      NVM_LOCAL_CURRENT="$(nvm_ls_current)"

      command mkdir -p "${NVM_LOCAL_ALIAS_DIR}/lts"

      local NVM_LOCAL_ALIAS
      local NVM_LOCAL_TARGET
      local NVM_LOCAL_NO_COLORS
      NVM_LOCAL_ALIAS='--'
      NVM_LOCAL_TARGET='--'

      while [ $# -gt 0 ]; do
        case "${1-}" in
          --) ;;
          --no-colors) NVM_LOCAL_NO_COLORS="${1}" ;;
          --*)
            nvm_err "Unsupported option \"${1}\"."
            return 55
          ;;
          *)
            if [ "${NVM_LOCAL_ALIAS}" = '--' ]; then
              NVM_LOCAL_ALIAS="${1-}"
            elif [ "${NVM_LOCAL_TARGET}" = '--' ]; then
              NVM_LOCAL_TARGET="${1-}"
            fi
          ;;
        esac
        shift
      done

      if [ -z "${NVM_LOCAL_TARGET}" ]; then
        # for some reason the empty string was explicitly passed as the target
        # so, unalias it.
        nvm unalias "${NVM_LOCAL_ALIAS}"
        return $?
      elif [ "${NVM_LOCAL_TARGET}" != '--' ]; then
        # a target was passed: create an alias
        if [ "${NVM_LOCAL_ALIAS#*\/}" != "${NVM_LOCAL_ALIAS}" ]; then
          nvm_err 'Aliases in subdirectories are not supported.'
          return 1
        fi
        NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_TARGET}")" ||:
        if [ "${NVM_LOCAL_VERSION}" = 'N/A' ]; then
          nvm_err "! WARNING: Version '${NVM_LOCAL_TARGET}' does not exist."
        fi
        nvm_make_alias "${NVM_LOCAL_ALIAS}" "${NVM_LOCAL_TARGET}"
        NVM_LOCAL_NO_COLORS="${NVM_LOCAL_NO_COLORS-}" NVM_LOCAL_CURRENT="${NVM_LOCAL_CURRENT-}" NVM_DEFAULT=false nvm_print_formatted_alias "${NVM_LOCAL_ALIAS}" "${NVM_LOCAL_TARGET}" "${NVM_LOCAL_VERSION}"
      else
        if [ "${NVM_LOCAL_ALIAS-}" = '--' ]; then
          unset NVM_LOCAL_ALIAS
        fi

        nvm_list_aliases "${NVM_LOCAL_ALIAS-}"
      fi
    ;;
    "unalias")
      local NVM_LOCAL_ALIAS_DIR
      NVM_LOCAL_ALIAS_DIR="$(nvm_alias_path)"
      command mkdir -p "${NVM_LOCAL_ALIAS_DIR}"
      if [ $# -ne 1 ]; then
        >&2 nvm --help
        return 127
      fi
      if [ "${1#*\/}" != "${1-}" ]; then
        nvm_err 'Aliases in subdirectories are not supported.'
        return 1
      fi

      local NVM_LOCAL_IOJS_PREFIX
      local NVM_LOCAL_NODE_PREFIX
      NVM_LOCAL_IOJS_PREFIX="$(nvm_iojs_prefix)"
      NVM_LOCAL_NODE_PREFIX="$(nvm_node_prefix)"
      local NVM_LOCAL_ALIAS_EXISTS
      NVM_LOCAL_ALIAS_EXISTS=0
      if [ -f "${NVM_LOCAL_ALIAS_DIR}/${1-}" ]; then
        NVM_LOCAL_ALIAS_EXISTS=1
      fi

      if [ ${NVM_LOCAL_ALIAS_EXISTS} -eq 0 ]; then
        case "$1" in
          "stable" | "unstable" | "${NVM_LOCAL_IOJS_PREFIX}" | "${NVM_LOCAL_NODE_PREFIX}" | "system")
            nvm_err "${1-} is a default (built-in) alias and cannot be deleted."
            return 1
          ;;
        esac

        nvm_err "Alias ${1-} doesn't exist!"
        return
      fi

      local NVM_LOCAL_ALIAS_ORIGINAL
      NVM_LOCAL_ALIAS_ORIGINAL="$(nvm_alias "${1}")"
      command rm -f "${NVM_LOCAL_ALIAS_DIR}/${1}"
      nvm_echo "Deleted alias ${1} - restore it with \`nvm alias \"${1}\" \"${NVM_LOCAL_ALIAS_ORIGINAL}\"\`"
    ;;
    "install-latest-npm")
      if [ $# -ne 0 ]; then
        >&2 nvm --help
        return 127
      fi

      nvm_install_latest_npm
    ;;
    "reinstall-packages" | "copy-packages")
      if [ $# -ne 1 ]; then
        >&2 nvm --help
        return 127
      fi

      local NVM_LOCAL_PROVIDED_VERSION
      NVM_LOCAL_PROVIDED_VERSION="${1-}"

      if [ "${NVM_LOCAL_PROVIDED_VERSION}" = "$(nvm_ls_current)" ] || [ "$(nvm_version "${NVM_LOCAL_PROVIDED_VERSION}" ||:)" = "$(nvm_ls_current)" ]; then
        nvm_err 'Can not reinstall packages from the current version of node.'
        return 2
      fi

      local NVM_LOCAL_VERSION
      if [ "_${NVM_LOCAL_PROVIDED_VERSION}" = "_system" ]; then
        if ! nvm_has_system_node && ! nvm_has_system_iojs; then
          nvm_err 'No system version of node or io.js detected.'
          return 3
        fi
        NVM_LOCAL_VERSION="system"
      else
        NVM_LOCAL_VERSION="$(nvm_version "${NVM_LOCAL_PROVIDED_VERSION}")" ||:
      fi

      local NVM_LOCAL_NPMLIST
      NVM_LOCAL_NPMLIST="$(nvm_npm_global_modules "${NVM_LOCAL_VERSION}")"
      local NVM_LOCAL_INSTALLS
      local NVM_LOCAL_LINKS
      NVM_LOCAL_INSTALLS="${NVM_LOCAL_NPMLIST%% //// *}"
      NVM_LOCAL_LINKS="${NVM_LOCAL_NPMLIST##* //// }"

      nvm_echo "Reinstalling global packages from ${NVM_LOCAL_VERSION}..."
      if [ -n "${NVM_LOCAL_INSTALLS}" ]; then
        nvm_echo "${NVM_LOCAL_INSTALLS}" | command xargs npm install -g --quiet
      else
        nvm_echo "No installed global packages found..."
      fi

      nvm_echo "Linking global packages from ${NVM_LOCAL_VERSION}..."
      if [ -n "${NVM_LOCAL_LINKS}" ]; then
        (
          set -f; IFS='
' # necessary to turn off variable expansion except for newlines
          for LINK in ${NVM_LOCAL_LINKS}; do
            set +f; unset IFS # restore variable expansion
            if [ -n "${LINK}" ]; then
              case "${LINK}" in
                '/'*) (nvm_cd "${LINK}" && npm link) ;;
                *) (nvm_cd "$(npm root -g)/../${LINK}" && npm link)
              esac
            fi
          done
        )
      else
        nvm_echo "No linked global packages found..."
      fi
    ;;
    "clear-cache")
      command rm -f "${NVM_DIR}/v*" "$(nvm_version_dir)" 2>/dev/null
      nvm_echo 'nvm cache cleared.'
    ;;
    "version")
      nvm_version "${1}"
    ;;
    "version-remote")
      local NVM_LOCAL_LTS
      local NVM_LOCAL_PATTERN
      while [ $# -gt 0 ]; do
        case "${1-}" in
          --) ;;
          --lts)
            NVM_LOCAL_LTS='*'
          ;;
          --lts=*)
            NVM_LOCAL_LTS="${1##--lts=}"
          ;;
          --*)
            nvm_err "Unsupported option \"${1}\"."
            return 55
          ;;
          *)
            NVM_LOCAL_PATTERN="${NVM_LOCAL_PATTERN:-${1}}"
          ;;
        esac
        shift
      done
      case "${NVM_LOCAL_PATTERN-}" in
        'lts/*')
          NVM_LOCAL_LTS='*'
          unset NVM_LOCAL_PATTERN
        ;;
        lts/*)
          NVM_LOCAL_LTS="${NVM_LOCAL_PATTERN##lts/}"
          unset NVM_LOCAL_PATTERN
        ;;
      esac
      NVM_VERSION_ONLY=true NVM_LOCAL_LTS="${NVM_LOCAL_LTS-}" nvm_remote_version "${NVM_LOCAL_PATTERN:-node}"
    ;;
    "--version" | "-v")
      nvm_echo '0.39.1'
    ;;
    "unload")
      nvm deactivate >/dev/null 2>&1
      unset -f nvm \
        nvm_iojs_prefix nvm_node_prefix \
        nvm_add_iojs_prefix nvm_strip_iojs_prefix \
        nvm_is_iojs_version nvm_is_alias nvm_has_non_aliased \
        nvm_ls_remote nvm_ls_remote_iojs nvm_ls_remote_index_tab \
        nvm_ls nvm_remote_version nvm_remote_versions \
        nvm_install_binary nvm_install_source nvm_clang_version \
        nvm_get_mirror nvm_get_download_slug nvm_download_artifact \
        nvm_install_npm_if_needed nvm_use_if_needed nvm_check_file_permissions \
        nvm_print_versions nvm_compute_checksum \
        nvm_get_checksum_binary \
        nvm_get_checksum_alg nvm_get_checksum nvm_compare_checksum \
        nvm_version nvm_rc_version nvm_match_version \
        nvm_ensure_default_set nvm_get_arch nvm_get_os \
        nvm_print_implicit_alias nvm_validate_implicit_alias \
        nvm_resolve_alias nvm_ls_current nvm_alias \
        nvm_binary_available nvm_change_path nvm_strip_path \
        nvm_num_version_groups nvm_format_version nvm_ensure_version_prefix \
        nvm_normalize_version nvm_is_valid_version nvm_normalize_lts \
        nvm_ensure_version_installed nvm_cache_dir \
        nvm_version_path nvm_alias_path nvm_version_dir \
        nvm_find_nvmrc nvm_find_up nvm_find_project_dir nvm_tree_contains_path \
        nvm_version_greater nvm_version_greater_than_or_equal_to \
        nvm_print_npm_version nvm_install_latest_npm nvm_npm_global_modules \
        nvm_has_system_node nvm_has_system_iojs \
        nvm_download nvm_get_latest nvm_has nvm_install_default_packages nvm_get_default_packages \
        nvm_curl_use_compression nvm_curl_version \
        nvm_auto nvm_supports_xz \
        nvm_echo nvm_err nvm_grep nvm_cd \
        nvm_die_on_prefix nvm_get_make_jobs nvm_get_minor_version \
        nvm_has_solaris_binary nvm_is_merged_node_version \
        nvm_is_natural_num nvm_is_version_installed \
        nvm_list_aliases nvm_make_alias nvm_print_alias_path \
        nvm_print_default_alias nvm_print_formatted_alias nvm_resolve_local_alias \
        nvm_sanitize_path nvm_has_colors nvm_process_parameters \
        nvm_node_version_has_solaris_binary nvm_iojs_version_has_solaris_binary \
        nvm_curl_libz_support nvm_command_info nvm_is_zsh nvm_stdout_is_terminal \
        nvm_npmrc_bad_news_bears \
        nvm_get_colors nvm_set_colors nvm_print_color_code nvm_format_help_message_colors \
        nvm_echo_with_colors nvm_err_with_colors \
        nvm_get_artifact_compression nvm_install_binary_extract nvm_extract_tarball \
        >/dev/null 2>&1
      unset NVM_RC_VERSION NVM_NODEJS_ORG_MIRROR NVM_IOJS_ORG_MIRROR NVM_DIR \
        NVM_CD_FLAGS NVM_BIN NVM_INC NVM_LOCAL_MAKE_JOBS \
        NVM_COLORS NVM_LOCAL_INSTALLED_COLOR NVM_LOCAL_SYSTEM_COLOR \
        NVM_LOCAL_CURRENT_COLOR NVM_LOCAL_NOT_INSTALLED_COLOR NVM_LOCAL_DEFAULT_COLOR NVM_LOCAL_LTS_COLOR \
        >/dev/null 2>&1
    ;;
    "set-colors")
      local NVM_LOCAL_EXIT_CODE
      nvm_set_colors "${1-}"
      NVM_LOCAL_EXIT_CODE=$?
      if [ "${NVM_LOCAL_EXIT_CODE}" -eq 17 ]; then
        >&2 nvm --help
        nvm_echo
        nvm_err_with_colors "\033[1;37mPlease pass in five \033[1;31mvalid color codes\033[1;37m. Choose from: rRgGbBcCyYmMkKeW\033[0m"
      fi
    ;;
    *)
      >&2 nvm --help
      return 127
    ;;
  esac
}

nvm_get_default_packages() {
  local NVM_LOCAL_DEFAULT_PACKAGE_FILE="${NVM_DIR}/default-packages"
  if [ -f "${NVM_LOCAL_DEFAULT_PACKAGE_FILE}" ]; then
    local NVM_LOCAL_DEFAULT_PACKAGES
    NVM_LOCAL_DEFAULT_PACKAGES=''

    # Read lines from ${NVM_DIR}/default-packages
    local NVM_LOCAL_LINE
    # ensure a trailing newline
    WORK=$(mktemp -d) || exit $?
    # shellcheck disable=SC2064
    trap "command rm -rf '${WORK}'" EXIT
    # shellcheck disable=SC1003
    sed -e '$a\' "${NVM_LOCAL_DEFAULT_PACKAGE_FILE}" > "${WORK}/default-packages"
    while IFS=' ' read -r NVM_LOCAL_LINE; do
      # Skip empty lines.
      [ -n "${NVM_LOCAL_LINE-}" ] || continue

      # Skip comment lines that begin with `#`.
      [ "$(nvm_echo "${NVM_LOCAL_LINE}" | command cut -c1)" != "#" ] || continue

      # Fail on lines that have multiple space-separated words
      case ${NVM_LOCAL_LINE} in
        *\ *)
          nvm_err "Only one package per line is allowed in the ${NVM_DIR}/default-packages file. Please remove any lines with multiple space-separated values."
          return 1
        ;;
      esac

      NVM_LOCAL_DEFAULT_PACKAGES="${NVM_LOCAL_DEFAULT_PACKAGES}${NVM_LOCAL_LINE} "
    done < "${WORK}/default-packages"
    echo "${NVM_LOCAL_DEFAULT_PACKAGES}" | command xargs
  fi
}

nvm_install_default_packages() {
  nvm_echo "Installing default global packages from ${NVM_DIR}/default-packages..."
  nvm_echo "npm install -g --quiet $1"

  if ! nvm_echo "$1" | command xargs npm install -g --quiet; then
    nvm_err "Failed installing default packages. Please check if your default-packages file or a package in it has problems!"
    return 1
  fi
}

nvm_supports_xz() {
  if [ -z "${1-}" ]; then
    return 1
  fi

  local NVM_LOCAL_OS
  NVM_LOCAL_OS="$(nvm_get_os)"
  if [ "_${NVM_LOCAL_OS}" = '_darwin' ]; then
    local NVM_LOCAL_MACOS_VERSION
    NVM_LOCAL_MACOS_VERSION="$(sw_vers -productVersion)"
    if nvm_version_greater "10.9.0" "${NVM_LOCAL_MACOS_VERSION}"; then
      # macOS 10.8 and earlier doesn't support extracting xz-compressed tarballs with tar
      return 1
    fi
  elif [ "_${NVM_LOCAL_OS}" = '_freebsd' ]; then
    if ! [ -e '/usr/lib/liblzma.so' ]; then
      # FreeBSD without /usr/lib/liblzma.so doesn't support extracting xz-compressed tarballs with tar
      return 1
    fi
  else
    if ! command which xz >/dev/null 2>&1; then
      # Most OSes without xz on the PATH don't support extracting xz-compressed tarballs with tar
      # (Should correctly handle Linux, SmartOS, maybe more)
      return 1
    fi
  fi

  # all node versions v4.0.0 and later have xz
  if nvm_is_merged_node_version "${1}"; then
    return 0
  fi

  # 0.12x: node v0.12.10 and later have xz
  if nvm_version_greater_than_or_equal_to "${1}" "0.12.10" && nvm_version_greater "0.13.0" "${1}"; then
    return 0
  fi

  # 0.10x: node v0.10.42 and later have xz
  if nvm_version_greater_than_or_equal_to "${1}" "0.10.42" && nvm_version_greater "0.11.0" "${1}"; then
    return 0
  fi

  case "${NVM_LOCAL_OS}" in
    darwin)
      # darwin only has xz for io.js v2.3.2 and later
      nvm_version_greater_than_or_equal_to "${1}" "2.3.2"
    ;;
    *)
      nvm_version_greater_than_or_equal_to "${1}" "1.0.0"
    ;;
  esac
  return $?
}

nvm_auto() {
  local NVM_LOCAL_MODE
  NVM_LOCAL_MODE="${1-}"
  local NVM_LOCAL_VERSION
  local NVM_LOCAL_CURRENT
  if [ "_${NVM_LOCAL_MODE}" = '_install' ]; then
    NVM_LOCAL_VERSION="$(nvm_alias default 2>/dev/null || nvm_echo)"
    if [ -n "${NVM_LOCAL_VERSION}" ]; then
      nvm install "${NVM_LOCAL_VERSION}" >/dev/null
    elif nvm_rc_version >/dev/null 2>&1; then
      nvm install >/dev/null
    fi
  elif [ "_${NVM_LOCAL_MODE}" = '_use' ]; then
    NVM_LOCAL_CURRENT="$(nvm_ls_current)"
    if [ "_${NVM_LOCAL_CURRENT}" = '_none' ] || [ "_${NVM_LOCAL_CURRENT}" = '_system' ]; then
      NVM_LOCAL_VERSION="$(nvm_resolve_local_alias default 2>/dev/null || nvm_echo)"
      if [ -n "${NVM_LOCAL_VERSION}" ]; then
        nvm use --silent "${NVM_LOCAL_VERSION}" >/dev/null
      elif nvm_rc_version >/dev/null 2>&1; then
        nvm use --silent >/dev/null
      fi
    else
      nvm use --silent "${NVM_LOCAL_CURRENT}" >/dev/null
    fi
  elif [ "_${NVM_LOCAL_MODE}" != '_none' ]; then
    nvm_err 'Invalid auto mode supplied.'
    return 1
  fi
}

nvm_process_parameters() {
  local NVM_LOCAL_AUTO_MODE
  NVM_LOCAL_AUTO_MODE='use'
  while [ "$#" -ne 0 ]; do
    case "$1" in
      --install) NVM_LOCAL_AUTO_MODE='install' ;;
      --no-use) NVM_LOCAL_AUTO_MODE='none' ;;
    esac
    shift
  done
  nvm_auto "${NVM_LOCAL_AUTO_MODE}"
}

nvm_process_parameters "$@"

} # this ensures the entire script is downloaded #
