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
  local COMMAND
  local INFO
  COMMAND="${1}"
  if type "${COMMAND}" | nvm_grep -q hashed; then
    INFO="$(type "${COMMAND}" | command sed -E 's/\(|\)//g' | command awk '{print $4}')"
  elif type "${COMMAND}" | nvm_grep -q aliased; then
    # shellcheck disable=SC2230
    INFO="$(which "${COMMAND}") ($(type "${COMMAND}" | command awk '{ $1=$2=$3=$4="" ;print }' | command sed -e 's/^\ *//g' -Ee "s/\`|'//g"))"
  elif type "${COMMAND}" | nvm_grep -q "^${COMMAND} is an alias for"; then
    # shellcheck disable=SC2230
    INFO="$(which "${COMMAND}") ($(type "${COMMAND}" | command awk '{ $1=$2=$3=$4=$5="" ;print }' | command sed 's/^\ *//g'))"
  elif type "${COMMAND}" | nvm_grep -q "^${COMMAND} is \\/"; then
    INFO="$(type "${COMMAND}" | command awk '{print $3}')"
  else
    INFO="$(type "${COMMAND}")"
  fi
  nvm_echo "${INFO}"
}

nvm_has_colors() {
  local NVM_NUM_COLORS
  if nvm_has tput; then
    NVM_NUM_COLORS="$(tput -T "${TERM:-vt100}" colors)"
  fi
  [ "${NVM_NUM_COLORS:--1}" -ge 8 ]
}

nvm_curl_libz_support() {
  curl -V 2>/dev/null | nvm_grep "^Features:" | nvm_grep -q "libz"
}

nvm_curl_use_compression() {
  nvm_curl_libz_support && nvm_version_greater_than_or_equal_to "$(nvm_curl_version)" 7.21.0
}

nvm_get_latest() {
  local NVM_LATEST_URL
  local CURL_COMPRESSED_FLAG
  if nvm_has "curl"; then
    if nvm_curl_use_compression; then
      CURL_COMPRESSED_FLAG="--compressed"
    fi
    NVM_LATEST_URL="$(curl ${CURL_COMPRESSED_FLAG:-} -q -w "%{url_effective}\\n" -L -s -S http://latest.nvm.sh -o /dev/null)"
  elif nvm_has "wget"; then
    NVM_LATEST_URL="$(wget -q http://latest.nvm.sh --server-response -O /dev/null 2>&1 | command awk '/^  Location: /{DEST=$2} END{ print DEST }')"
  else
    nvm_err 'nvm needs curl or wget to proceed.'
    return 1
  fi
  if [ -z "${NVM_LATEST_URL}" ]; then
    nvm_err "http://latest.nvm.sh did not redirect to the latest release on GitHub"
    return 2
  fi
  nvm_echo "${NVM_LATEST_URL##*/}"
}

nvm_download() {
  local CURL_COMPRESSED_FLAG
  if nvm_has "curl"; then
    if nvm_curl_use_compression; then
      CURL_COMPRESSED_FLAG="--compressed"
    fi
    curl --fail ${CURL_COMPRESSED_FLAG:-} -q "$@"
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
    eval wget $ARGS
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
  local NVM_NODE_BINARY
  NVM_NODE_BINARY='node'
  if [ "_$(nvm_get_os)" = '_win' ]; then
    NVM_NODE_BINARY='node.exe'
  fi
  if [ -x "$(nvm_version_path "$1" 2>/dev/null)/bin/${NVM_NODE_BINARY}" ]; then
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
  local NODE_VERSION
  NODE_VERSION="$(nvm_strip_iojs_prefix "$(nvm_ls_current)")"
  if [ "${NODE_VERSION}" = 'system' ]; then
    NODE_VERSION="$(node --version)"
  elif [ "${NODE_VERSION}" = 'none' ]; then
    nvm_echo "Detected node version ${NODE_VERSION}, npm version v${NPM_VERSION}"
    NODE_VERSION=''
  fi
  if [ -z "${NODE_VERSION}" ]; then
    nvm_err 'Unable to obtain node version.'
    return 1
  fi
  local NPM_VERSION
  NPM_VERSION="$(npm --version 2>/dev/null)"
  if [ -z "${NPM_VERSION}" ]; then
    nvm_err 'Unable to obtain npm version.'
    return 2
  fi

  local NVM_NPM_CMD
  NVM_NPM_CMD='npm'
  if [ "${NVM_DEBUG-}" = 1 ]; then
    nvm_echo "Detected node version ${NODE_VERSION}, npm version v${NPM_VERSION}"
    NVM_NPM_CMD='nvm_echo npm'
  fi

  local NVM_IS_0_6
  NVM_IS_0_6=0
  if nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 0.6.0 && nvm_version_greater 0.7.0 "${NODE_VERSION}"; then
    NVM_IS_0_6=1
  fi
  local NVM_IS_0_9
  NVM_IS_0_9=0
  if nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 0.9.0 && nvm_version_greater 0.10.0 "${NODE_VERSION}"; then
    NVM_IS_0_9=1
  fi

  if [ $NVM_IS_0_6 -eq 1 ]; then
    nvm_echo '* `node` v0.6.x can only upgrade to `npm` v1.3.x'
    $NVM_NPM_CMD install -g npm@1.3
  elif [ $NVM_IS_0_9 -eq 0 ]; then
    # node 0.9 breaks here, for some reason
    if nvm_version_greater_than_or_equal_to "${NPM_VERSION}" 1.0.0 && nvm_version_greater 2.0.0 "${NPM_VERSION}"; then
      nvm_echo '* `npm` v1.x needs to first jump to `npm` v1.4.28 to be able to upgrade further'
      $NVM_NPM_CMD install -g npm@1.4.28
    elif nvm_version_greater_than_or_equal_to "${NPM_VERSION}" 2.0.0 && nvm_version_greater 3.0.0 "${NPM_VERSION}"; then
      nvm_echo '* `npm` v2.x needs to first jump to the latest v2 to be able to upgrade further'
      $NVM_NPM_CMD install -g npm@2
    fi
  fi

  if [ $NVM_IS_0_9 -eq 1 ] || [ $NVM_IS_0_6 -eq 1 ]; then
    nvm_echo '* node v0.6 and v0.9 are unable to upgrade further'
  elif nvm_version_greater 1.1.0 "${NODE_VERSION}"; then
    nvm_echo '* `npm` v4.5.x is the last version that works on `node` versions < v1.1.0'
    $NVM_NPM_CMD install -g npm@4.5
  elif nvm_version_greater 4.0.0 "${NODE_VERSION}"; then
    nvm_echo '* `npm` v5 and higher do not work on `node` versions below v4.0.0'
    $NVM_NPM_CMD install -g npm@4
  elif [ $NVM_IS_0_9 -eq 0 ] && [ $NVM_IS_0_6 -eq 0 ]; then
    local NVM_IS_4_4_OR_BELOW
    NVM_IS_4_4_OR_BELOW=0
    if nvm_version_greater 4.5.0 "${NODE_VERSION}"; then
      NVM_IS_4_4_OR_BELOW=1
    fi

    local NVM_IS_5_OR_ABOVE
    NVM_IS_5_OR_ABOVE=0
    if [ $NVM_IS_4_4_OR_BELOW -eq 0 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 5.0.0; then
      NVM_IS_5_OR_ABOVE=1
    fi

    local NVM_IS_6_OR_ABOVE
    NVM_IS_6_OR_ABOVE=0
    local NVM_IS_6_2_OR_ABOVE
    NVM_IS_6_2_OR_ABOVE=0
    if [ $NVM_IS_5_OR_ABOVE -eq 1 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 6.0.0; then
      NVM_IS_6_OR_ABOVE=1
      if nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 6.2.0; then
        NVM_IS_6_2_OR_ABOVE=1
      fi
    fi

    local NVM_IS_9_OR_ABOVE
    NVM_IS_9_OR_ABOVE=0
    local NVM_IS_9_3_OR_ABOVE
    NVM_IS_9_3_OR_ABOVE=0
    if [ $NVM_IS_6_2_OR_ABOVE -eq 1 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 9.0.0; then
      NVM_IS_9_OR_ABOVE=1
      if nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 9.3.0; then
        NVM_IS_9_3_OR_ABOVE=1
      fi
    fi

    local NVM_IS_10_OR_ABOVE
    NVM_IS_10_OR_ABOVE=0
    if [ $NVM_IS_9_3_OR_ABOVE -eq 1 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 10.0.0; then
      NVM_IS_10_OR_ABOVE=1
    fi
    local NVM_IS_12_LTS_OR_ABOVE
    NVM_IS_12_LTS_OR_ABOVE=0
    if [ $NVM_IS_10_OR_ABOVE -eq 1 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 12.13.0; then
      NVM_IS_12_LTS_OR_ABOVE=1
    fi
    local NVM_IS_13_OR_ABOVE
    NVM_IS_13_OR_ABOVE=0
    if [ $NVM_IS_12_LTS_OR_ABOVE -eq 1 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 13.0.0; then
      NVM_IS_13_OR_ABOVE=1
    fi
    local NVM_IS_14_LTS_OR_ABOVE
    NVM_IS_14_LTS_OR_ABOVE=0
    if [ $NVM_IS_13_OR_ABOVE -eq 1 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 14.15.0; then
      NVM_IS_14_LTS_OR_ABOVE=1
    fi
    local NVM_IS_15_OR_ABOVE
    NVM_IS_15_OR_ABOVE=0
    if [ $NVM_IS_14_LTS_OR_ABOVE -eq 1 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 15.0.0; then
      NVM_IS_15_OR_ABOVE=1
    fi
    local NVM_IS_16_OR_ABOVE
    NVM_IS_16_OR_ABOVE=0
    if [ $NVM_IS_15_OR_ABOVE -eq 1 ] && nvm_version_greater_than_or_equal_to "${NODE_VERSION}" 16.0.0; then
      NVM_IS_16_OR_ABOVE=1
    fi

    if [ $NVM_IS_4_4_OR_BELOW -eq 1 ] || {
      [ $NVM_IS_5_OR_ABOVE -eq 1 ] && nvm_version_greater 5.10.0 "${NODE_VERSION}"; \
    }; then
      nvm_echo '* `npm` `v5.3.x` is the last version that works on `node` 4.x versions below v4.4, or 5.x versions below v5.10, due to `Buffer.alloc`'
      $NVM_NPM_CMD install -g npm@5.3
    elif [ $NVM_IS_4_4_OR_BELOW -eq 0 ] && nvm_version_greater 4.7.0 "${NODE_VERSION}"; then
      nvm_echo '* `npm` `v5.4.1` is the last version that works on `node` `v4.5` and `v4.6`'
      $NVM_NPM_CMD install -g npm@5.4.1
    elif [ $NVM_IS_6_OR_ABOVE -eq 0 ]; then
      nvm_echo '* `npm` `v5.x` is the last version that works on `node` below `v6.0.0`'
      $NVM_NPM_CMD install -g npm@5
    elif \
      { [ $NVM_IS_6_OR_ABOVE -eq 1 ] && [ $NVM_IS_6_2_OR_ABOVE -eq 0 ]; } \
      || { [ $NVM_IS_9_OR_ABOVE -eq 1 ] && [ $NVM_IS_9_3_OR_ABOVE -eq 0 ]; } \
    ; then
      nvm_echo '* `npm` `v6.9` is the last version that works on `node` `v6.0.x`, `v6.1.x`, `v9.0.x`, `v9.1.x`, or `v9.2.x`'
      $NVM_NPM_CMD install -g npm@6.9
    elif [ $NVM_IS_10_OR_ABOVE -eq 0 ]; then
      nvm_echo '* `npm` `v6.x` is the last version that works on `node` below `v10.0.0`'
      $NVM_NPM_CMD install -g npm@6
    elif \
      [ $NVM_IS_12_LTS_OR_ABOVE -eq 0 ] \
      || { [ $NVM_IS_13_OR_ABOVE -eq 1 ] && [ $NVM_IS_14_LTS_OR_ABOVE -eq 0 ]; } \
      || { [ $NVM_IS_15_OR_ABOVE -eq 1 ] && [ $NVM_IS_16_OR_ABOVE -eq 0 ]; } \
    ; then
      nvm_echo '* `npm` `v7.x` is the last version that works on `node` `v13`, `v15`, below `v12.13`, or `v14.0` - `v14.15`'
      $NVM_NPM_CMD install -g npm@7
    else
      nvm_echo '* Installing latest `npm`; if this does not work on your node version, please report a bug!'
      $NVM_NPM_CMD install -g npm
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
  case $NVM_DIR in
    *[!/]*/)
      NVM_DIR="${NVM_DIR%"${NVM_DIR##*[!/]}"}"
      export NVM_DIR
      nvm_err "Warning: \$NVM_DIR should not have trailing slashes"
    ;;
  esac
fi
unset NVM_SCRIPT_SOURCE 2>/dev/null

nvm_tree_contains_path() {
  local tree
  tree="${1-}"
  local node_path
  node_path="${2-}"

  if [ "@${tree}@" = "@@" ] || [ "@${node_path}@" = "@@" ]; then
    nvm_err "both the tree and the node path are required"
    return 2
  fi

  local previous_pathdir
  previous_pathdir="${node_path}"
  local pathdir
  pathdir=$(dirname "${previous_pathdir}")
  while [ "${pathdir}" != '' ] && [ "${pathdir}" != '.' ] && [ "${pathdir}" != '/' ] &&
      [ "${pathdir}" != "${tree}" ] && [ "${pathdir}" != "${previous_pathdir}" ]; do
    previous_pathdir="${pathdir}"
    pathdir=$(dirname "${previous_pathdir}")
  done
  [ "${pathdir}" = "${tree}" ]
}

nvm_find_project_dir() {
  local path_
  path_="${PWD}"
  while [ "${path_}" != "" ] && [ ! -f "${path_}/package.json" ] && [ ! -d "${path_}/node_modules" ]; do
    path_=${path_%/*}
  done
  nvm_echo "${path_}"
}

# Traverse up in directory tree to find containing folder
nvm_find_up() {
  local path_
  path_="${PWD}"
  while [ "${path_}" != "" ] && [ ! -f "${path_}/${1-}" ]; do
    path_=${path_%/*}
  done
  nvm_echo "${path_}"
}

nvm_find_nvmrc() {
  local dir
  dir="$(nvm_find_up '.nvmrc')"
  if [ -e "${dir}/.nvmrc" ]; then
    nvm_echo "${dir}/.nvmrc"
  fi
}

# Obtain nvm version from rc file
nvm_rc_version() {
  export NVM_RC_VERSION=''
  local NVMRC_PATH
  NVMRC_PATH="$(nvm_find_nvmrc)"
  if [ ! -e "${NVMRC_PATH}" ]; then
    if [ "${NVM_SILENT:-0}" -ne 1 ]; then
      nvm_err "No .nvmrc file found"
    fi
    return 1
  fi
  NVM_RC_VERSION="$(command head -n 1 "${NVMRC_PATH}" | command tr -d '\r')" || command printf ''
  if [ -z "${NVM_RC_VERSION}" ]; then
    if [ "${NVM_SILENT:-0}" -ne 1 ]; then
      nvm_err "Warning: empty .nvmrc file found at \"${NVMRC_PATH}\""
    fi
    return 2
  fi
  if [ "${NVM_SILENT:-0}" -ne 1 ]; then
    nvm_echo "Found '${NVMRC_PATH}' with version <${NVM_RC_VERSION}>"
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
  local NVM_WHICH_DIR
  NVM_WHICH_DIR="${1-}"
  if [ -z "${NVM_WHICH_DIR}" ] || [ "${NVM_WHICH_DIR}" = "new" ]; then
    nvm_echo "${NVM_DIR}/versions/node"
  elif [ "_${NVM_WHICH_DIR}" = "_iojs" ]; then
    nvm_echo "${NVM_DIR}/versions/io.js"
  elif [ "_${NVM_WHICH_DIR}" = "_old" ]; then
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
  local VERSION
  VERSION="${1-}"
  if [ -z "${VERSION}" ]; then
    nvm_err 'version is required'
    return 3
  elif nvm_is_iojs_version "${VERSION}"; then
    nvm_echo "$(nvm_version_dir iojs)/$(nvm_strip_iojs_prefix "${VERSION}")"
  elif nvm_version_greater 0.12.0 "${VERSION}"; then
    nvm_echo "$(nvm_version_dir old)/${VERSION}"
  else
    nvm_echo "$(nvm_version_dir new)/${VERSION}"
  fi
}

nvm_ensure_version_installed() {
  local PROVIDED_VERSION
  PROVIDED_VERSION="${1-}"
  if [ "${PROVIDED_VERSION}" = 'system' ]; then
    if nvm_has_system_iojs || nvm_has_system_node; then
      return 0
    fi
    nvm_err "N/A: no system version of node/io.js is installed."
    return 1
  fi
  local LOCAL_VERSION
  local EXIT_CODE
  LOCAL_VERSION="$(nvm_version "${PROVIDED_VERSION}")"
  EXIT_CODE="$?"
  local NVM_VERSION_DIR
  if [ "${EXIT_CODE}" != "0" ] || ! nvm_is_version_installed "${LOCAL_VERSION}"; then
    if VERSION="$(nvm_resolve_alias "${PROVIDED_VERSION}")"; then
      nvm_err "N/A: version \"${PROVIDED_VERSION} -> ${VERSION}\" is not yet installed."
    else
      local PREFIXED_VERSION
      PREFIXED_VERSION="$(nvm_ensure_version_prefix "${PROVIDED_VERSION}")"
      nvm_err "N/A: version \"${PREFIXED_VERSION:-$PROVIDED_VERSION}\" is not yet installed."
    fi
    nvm_err ""
    nvm_err "You need to run \"nvm install ${PROVIDED_VERSION}\" to install it before using it."
    return 1
  fi
}

# Expand a version using the version cache
nvm_version() {
  local PATTERN
  PATTERN="${1-}"
  local VERSION
  # The default version is the current one
  if [ -z "${PATTERN}" ]; then
    PATTERN='current'
  fi

  if [ "${PATTERN}" = "current" ]; then
    nvm_ls_current
    return $?
  fi

  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"
  case "_${PATTERN}" in
    "_${NVM_NODE_PREFIX}" | "_${NVM_NODE_PREFIX}-")
      PATTERN="stable"
    ;;
  esac
  VERSION="$(nvm_ls "${PATTERN}" | command tail -1)"
  if [ -z "${VERSION}" ] || [ "_${VERSION}" = "_N/A" ]; then
    nvm_echo "N/A"
    return 3
  fi
  nvm_echo "${VERSION}"
}

nvm_remote_version() {
  local PATTERN
  PATTERN="${1-}"
  local VERSION
  if nvm_validate_implicit_alias "${PATTERN}" 2>/dev/null; then
    case "${PATTERN}" in
      "$(nvm_iojs_prefix)")
        VERSION="$(NVM_LTS="${NVM_LTS-}" nvm_ls_remote_iojs | command tail -1)" &&:
      ;;
      *)
        VERSION="$(NVM_LTS="${NVM_LTS-}" nvm_ls_remote "${PATTERN}")" &&:
      ;;
    esac
  else
    VERSION="$(NVM_LTS="${NVM_LTS-}" nvm_remote_versions "${PATTERN}" | command tail -1)"
  fi
  if [ -n "${NVM_VERSION_ONLY-}" ]; then
    command awk 'BEGIN {
      n = split(ARGV[1], a);
      print a[1]
    }' "${VERSION}"
  else
    nvm_echo "${VERSION}"
  fi
  if [ "${VERSION}" = 'N/A' ]; then
    return 3
  fi
}

nvm_remote_versions() {
  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"

  local PATTERN
  PATTERN="${1-}"

  local NVM_FLAVOR
  if [ -n "${NVM_LTS-}" ]; then
    NVM_FLAVOR="${NVM_NODE_PREFIX}"
  fi

  case "${PATTERN}" in
    "${NVM_IOJS_PREFIX}" | "io.js")
      NVM_FLAVOR="${NVM_IOJS_PREFIX}"
      unset PATTERN
    ;;
    "${NVM_NODE_PREFIX}")
      NVM_FLAVOR="${NVM_NODE_PREFIX}"
      unset PATTERN
    ;;
  esac

  if nvm_validate_implicit_alias "${PATTERN-}" 2>/dev/null; then
    nvm_err 'Implicit aliases are not supported in nvm_remote_versions.'
    return 1
  fi

  local NVM_LS_REMOTE_EXIT_CODE
  NVM_LS_REMOTE_EXIT_CODE=0
  local NVM_LS_REMOTE_PRE_MERGED_OUTPUT
  NVM_LS_REMOTE_PRE_MERGED_OUTPUT=''
  local NVM_LS_REMOTE_POST_MERGED_OUTPUT
  NVM_LS_REMOTE_POST_MERGED_OUTPUT=''
  if [ -z "${NVM_FLAVOR-}" ] || [ "${NVM_FLAVOR-}" = "${NVM_NODE_PREFIX}" ]; then
    local NVM_LS_REMOTE_OUTPUT
    # extra space is needed here to avoid weird behavior when `nvm_ls_remote` ends in a `*`
    NVM_LS_REMOTE_OUTPUT="$(NVM_LTS="${NVM_LTS-}" nvm_ls_remote "${PATTERN-}") " &&:
    NVM_LS_REMOTE_EXIT_CODE=$?
    # split output into two
    NVM_LS_REMOTE_PRE_MERGED_OUTPUT="${NVM_LS_REMOTE_OUTPUT%%v4\.0\.0*}"
    NVM_LS_REMOTE_POST_MERGED_OUTPUT="${NVM_LS_REMOTE_OUTPUT#"$NVM_LS_REMOTE_PRE_MERGED_OUTPUT"}"
  fi

  local NVM_LS_REMOTE_IOJS_EXIT_CODE
  NVM_LS_REMOTE_IOJS_EXIT_CODE=0
  local NVM_LS_REMOTE_IOJS_OUTPUT
  NVM_LS_REMOTE_IOJS_OUTPUT=''
  if [ -z "${NVM_LTS-}" ] && {
    [ -z "${NVM_FLAVOR-}" ] || [ "${NVM_FLAVOR-}" = "${NVM_IOJS_PREFIX}" ];
  }; then
    NVM_LS_REMOTE_IOJS_OUTPUT=$(nvm_ls_remote_iojs "${PATTERN-}") &&:
    NVM_LS_REMOTE_IOJS_EXIT_CODE=$?
  fi

  # the `sed` removes both blank lines, and only-whitespace lines (see "weird behavior" ~19 lines up)
  VERSIONS="$(nvm_echo "${NVM_LS_REMOTE_PRE_MERGED_OUTPUT}
${NVM_LS_REMOTE_IOJS_OUTPUT}
${NVM_LS_REMOTE_POST_MERGED_OUTPUT}" | nvm_grep -v "N/A" | command sed '/^ *$/d')"

  if [ -z "${VERSIONS}" ]; then
    nvm_echo 'N/A'
    return 3
  fi
  # the `sed` is to remove trailing whitespaces (see "weird behavior" ~25 lines up)
  nvm_echo "${VERSIONS}" | command sed 's/ *$//g'
  return $NVM_LS_REMOTE_EXIT_CODE || $NVM_LS_REMOTE_IOJS_EXIT_CODE
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
      local VERSION
      VERSION="$(nvm_strip_iojs_prefix "${1-}")"
      nvm_version_greater_than_or_equal_to "${VERSION}" 0
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
  local LTS
  LTS="${1-}"

  if [ "$(expr "${LTS}" : '^lts/-[1-9][0-9]*$')" -gt 0 ]; then
    local N
    N="$(echo "${LTS}" | cut -d '-' -f 2)"
    N=$((N+1))
    local NVM_ALIAS_DIR
    NVM_ALIAS_DIR="$(nvm_alias_path)"
    local RESULT
    RESULT="$(command ls "${NVM_ALIAS_DIR}/lts" | command tail -n "${N}" | command head -n 1)"
    if [ "${RESULT}" != '*' ]; then
      nvm_echo "lts/${RESULT}"
    else
      nvm_err 'That many LTS releases do not exist yet.'
      return 2
    fi
  else
    nvm_echo "${LTS}"
  fi
}

nvm_ensure_version_prefix() {
  local NVM_VERSION
  NVM_VERSION="$(nvm_strip_iojs_prefix "${1-}" | command sed -e 's/^\([0-9]\)/v\1/g')"
  if nvm_is_iojs_version "${1-}"; then
    nvm_add_iojs_prefix "${NVM_VERSION}"
  else
    nvm_echo "${NVM_VERSION}"
  fi
}

nvm_format_version() {
  local VERSION
  VERSION="$(nvm_ensure_version_prefix "${1-}")"
  local NUM_GROUPS
  NUM_GROUPS="$(nvm_num_version_groups "${VERSION}")"
  if [ "${NUM_GROUPS}" -lt 3 ]; then
    nvm_format_version "${VERSION%.}.0"
  else
    nvm_echo "${VERSION}" | command cut -f1-3 -d.
  fi
}

nvm_num_version_groups() {
  local VERSION
  VERSION="${1-}"
  VERSION="${VERSION#v}"
  VERSION="${VERSION%.}"
  if [ -z "${VERSION}" ]; then
    nvm_echo "0"
    return
  fi
  local NVM_NUM_DOTS
  NVM_NUM_DOTS=$(nvm_echo "${VERSION}" | command sed -e 's/[^\.]//g')
  local NVM_NUM_GROUPS
  NVM_NUM_GROUPS=".${NVM_NUM_DOTS}" # add extra dot, since it's (n - 1) dots at this point
  nvm_echo "${#NVM_NUM_GROUPS}"
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
    local INSTALLED_COLOR
    local LTS_AND_SYSTEM_COLOR
    local CURRENT_COLOR
    local NOT_INSTALLED_COLOR
    local DEFAULT_COLOR

    INSTALLED_COLOR="$(echo "$1" | awk '{ print substr($0, 1, 1); }')"
    LTS_AND_SYSTEM_COLOR="$(echo "$1" | awk '{ print substr($0, 2, 1); }')"
    CURRENT_COLOR="$(echo "$1" | awk '{ print substr($0, 3, 1); }')"
    NOT_INSTALLED_COLOR="$(echo "$1" | awk '{ print substr($0, 4, 1); }')"
    DEFAULT_COLOR="$(echo "$1" | awk '{ print substr($0, 5, 1); }')"
    if ! nvm_has_colors; then
      nvm_echo "Setting colors to: ${INSTALLED_COLOR} ${LTS_AND_SYSTEM_COLOR} ${CURRENT_COLOR} ${NOT_INSTALLED_COLOR} ${DEFAULT_COLOR}"
      nvm_echo "WARNING: Colors may not display because they are not supported in this shell."
    else
      nvm_echo_with_colors "Setting colors to: \033[$(nvm_print_color_code "${INSTALLED_COLOR}") ${INSTALLED_COLOR}\033[$(nvm_print_color_code "${LTS_AND_SYSTEM_COLOR}") ${LTS_AND_SYSTEM_COLOR}\033[$(nvm_print_color_code "${CURRENT_COLOR}") ${CURRENT_COLOR}\033[$(nvm_print_color_code "${NOT_INSTALLED_COLOR}") ${NOT_INSTALLED_COLOR}\033[$(nvm_print_color_code "${DEFAULT_COLOR}") ${DEFAULT_COLOR}\033[0m"
    fi
    export NVM_COLORS="$1"
  else
    return 17
  fi
}

nvm_get_colors() {
  local COLOR
  local SYS_COLOR
  if [ -n "${NVM_COLORS-}" ]; then
    case $1 in
      1) COLOR=$(nvm_print_color_code "$(echo "$NVM_COLORS" | awk '{ print substr($0, 1, 1); }')");;
      2) COLOR=$(nvm_print_color_code "$(echo "$NVM_COLORS" | awk '{ print substr($0, 2, 1); }')");;
      3) COLOR=$(nvm_print_color_code "$(echo "$NVM_COLORS" | awk '{ print substr($0, 3, 1); }')");;
      4) COLOR=$(nvm_print_color_code "$(echo "$NVM_COLORS" | awk '{ print substr($0, 4, 1); }')");;
      5) COLOR=$(nvm_print_color_code "$(echo "$NVM_COLORS" | awk '{ print substr($0, 5, 1); }')");;
      6)
        SYS_COLOR=$(nvm_print_color_code "$(echo "$NVM_COLORS" | awk '{ print substr($0, 2, 1); }')")
        COLOR=$(nvm_echo "$SYS_COLOR" | command tr '0;' '1;')
        ;;
      *)
        nvm_err "Invalid color index, ${1-}"
        return 1
      ;;
    esac
  else
    case $1 in
      1) COLOR='0;34m';;
      2) COLOR='0;33m';;
      3) COLOR='0;32m';;
      4) COLOR='0;31m';;
      5) COLOR='0;37m';;
      6) COLOR='1;33m';;
      *)
        nvm_err "Invalid color index, ${1-}"
        return 1
      ;;
    esac
  fi

  echo "$COLOR"
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
  local ALIAS
  ALIAS="${1-}"
  local DEST
  DEST="${2-}"
  local VERSION
  VERSION="${3-}"
  if [ -z "${VERSION}" ]; then
    VERSION="$(nvm_version "${DEST}")" ||:
  fi
  local VERSION_FORMAT
  local ALIAS_FORMAT
  local DEST_FORMAT

  local INSTALLED_COLOR
  local SYSTEM_COLOR
  local CURRENT_COLOR
  local NOT_INSTALLED_COLOR
  local DEFAULT_COLOR
  local LTS_COLOR

  INSTALLED_COLOR=$(nvm_get_colors 1)
  SYSTEM_COLOR=$(nvm_get_colors 2)
  CURRENT_COLOR=$(nvm_get_colors 3)
  NOT_INSTALLED_COLOR=$(nvm_get_colors 4)
  DEFAULT_COLOR=$(nvm_get_colors 5)
  LTS_COLOR=$(nvm_get_colors 6)

  ALIAS_FORMAT='%s'
  DEST_FORMAT='%s'
  VERSION_FORMAT='%s'
  local NEWLINE
  NEWLINE='\n'
  if [ "_${DEFAULT}" = '_true' ]; then
    NEWLINE=' (default)\n'
  fi
  local ARROW
  ARROW='->'
  if [ -z "${NVM_NO_COLORS}" ] && nvm_has_colors; then
    ARROW='\033[0;90m->\033[0m'
    if [ "_${DEFAULT}" = '_true' ]; then
      NEWLINE=" \033[${DEFAULT_COLOR}(default)\033[0m\n"
    fi
    if [ "_${VERSION}" = "_${NVM_CURRENT-}" ]; then
      ALIAS_FORMAT="\033[${CURRENT_COLOR}%s\033[0m"
      DEST_FORMAT="\033[${CURRENT_COLOR}%s\033[0m"
      VERSION_FORMAT="\033[${CURRENT_COLOR}%s\033[0m"
    elif nvm_is_version_installed "${VERSION}"; then
      ALIAS_FORMAT="\033[${INSTALLED_COLOR}%s\033[0m"
      DEST_FORMAT="\033[${INSTALLED_COLOR}%s\033[0m"
      VERSION_FORMAT="\033[${INSTALLED_COLOR}%s\033[0m"
    elif [ "${VERSION}" = '∞' ] || [ "${VERSION}" = 'N/A' ]; then
      ALIAS_FORMAT="\033[${NOT_INSTALLED_COLOR}%s\033[0m"
      DEST_FORMAT="\033[${NOT_INSTALLED_COLOR}%s\033[0m"
      VERSION_FORMAT="\033[${NOT_INSTALLED_COLOR}%s\033[0m"
    fi
    if [ "_${NVM_LTS-}" = '_true' ]; then
      ALIAS_FORMAT="\033[${LTS_COLOR}%s\033[0m"
    fi
    if [ "_${DEST%/*}" = "_lts" ]; then
      DEST_FORMAT="\033[${LTS_COLOR}%s\033[0m"
    fi
  elif [ "_${VERSION}" != '_∞' ] && [ "_${VERSION}" != '_N/A' ]; then
    VERSION_FORMAT='%s *'
  fi
  if [ "${DEST}" = "${VERSION}" ]; then
    command printf -- "${ALIAS_FORMAT} ${ARROW} ${VERSION_FORMAT}${NEWLINE}" "${ALIAS}" "${DEST}"
  else
    command printf -- "${ALIAS_FORMAT} ${ARROW} ${DEST_FORMAT} (${ARROW} ${VERSION_FORMAT})${NEWLINE}" "${ALIAS}" "${DEST}" "${VERSION}"
  fi
}

nvm_print_alias_path() {
  local NVM_ALIAS_DIR
  NVM_ALIAS_DIR="${1-}"
  if [ -z "${NVM_ALIAS_DIR}" ]; then
    nvm_err 'An alias dir is required.'
    return 1
  fi
  local ALIAS_PATH
  ALIAS_PATH="${2-}"
  if [ -z "${ALIAS_PATH}" ]; then
    nvm_err 'An alias path is required.'
    return 2
  fi
  local ALIAS
  ALIAS="${ALIAS_PATH##"${NVM_ALIAS_DIR}"\/}"
  local DEST
  DEST="$(nvm_alias "${ALIAS}" 2>/dev/null)" ||:
  if [ -n "${DEST}" ]; then
    NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_LTS="${NVM_LTS-}" DEFAULT=false nvm_print_formatted_alias "${ALIAS}" "${DEST}"
  fi
}

nvm_print_default_alias() {
  local ALIAS
  ALIAS="${1-}"
  if [ -z "${ALIAS}" ]; then
    nvm_err 'A default alias is required.'
    return 1
  fi
  local DEST
  DEST="$(nvm_print_implicit_alias local "${ALIAS}")"
  if [ -n "${DEST}" ]; then
    NVM_NO_COLORS="${NVM_NO_COLORS-}" DEFAULT=true nvm_print_formatted_alias "${ALIAS}" "${DEST}"
  fi
}

nvm_make_alias() {
  local ALIAS
  ALIAS="${1-}"
  if [ -z "${ALIAS}" ]; then
    nvm_err "an alias name is required"
    return 1
  fi
  local VERSION
  VERSION="${2-}"
  if [ -z "${VERSION}" ]; then
    nvm_err "an alias target version is required"
    return 2
  fi
  nvm_echo "${VERSION}" | tee "$(nvm_alias_path)/${ALIAS}" >/dev/null
}

nvm_list_aliases() {
  local ALIAS
  ALIAS="${1-}"

  local NVM_CURRENT
  NVM_CURRENT="$(nvm_ls_current)"
  local NVM_ALIAS_DIR
  NVM_ALIAS_DIR="$(nvm_alias_path)"
  command mkdir -p "${NVM_ALIAS_DIR}/lts"

  if [ "${ALIAS}" != "${ALIAS#lts/}" ]; then
    nvm_alias "${ALIAS}"
    return $?
  fi

  nvm_is_zsh && unsetopt local_options nomatch
  (
    local ALIAS_PATH
    for ALIAS_PATH in "${NVM_ALIAS_DIR}/${ALIAS}"*; do
      NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_CURRENT="${NVM_CURRENT}" nvm_print_alias_path "${NVM_ALIAS_DIR}" "${ALIAS_PATH}" &
    done
    wait
  ) | sort

  (
    local ALIAS_NAME
    for ALIAS_NAME in "$(nvm_node_prefix)" "stable" "unstable"; do
      {
        # shellcheck disable=SC2030,SC2031 # (https://github.com/koalaman/shellcheck/issues/2217)
        if [ ! -f "${NVM_ALIAS_DIR}/${ALIAS_NAME}" ] && { [ -z "${ALIAS}" ] || [ "${ALIAS_NAME}" = "${ALIAS}" ]; }; then
          NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_CURRENT="${NVM_CURRENT}" nvm_print_default_alias "${ALIAS_NAME}"
        fi
      } &
    done
    wait
    ALIAS_NAME="$(nvm_iojs_prefix)"
    # shellcheck disable=SC2030,SC2031 # (https://github.com/koalaman/shellcheck/issues/2217)
    if [ ! -f "${NVM_ALIAS_DIR}/${ALIAS_NAME}" ] && { [ -z "${ALIAS}" ] || [ "${ALIAS_NAME}" = "${ALIAS}" ]; }; then
      NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_CURRENT="${NVM_CURRENT}" nvm_print_default_alias "${ALIAS_NAME}"
    fi
  ) | sort

  (
    local LTS_ALIAS
    # shellcheck disable=SC2030,SC2031 # (https://github.com/koalaman/shellcheck/issues/2217)
    for ALIAS_PATH in "${NVM_ALIAS_DIR}/lts/${ALIAS}"*; do
      {
        LTS_ALIAS="$(NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_LTS=true nvm_print_alias_path "${NVM_ALIAS_DIR}" "${ALIAS_PATH}")"
        if [ -n "${LTS_ALIAS}" ]; then
          nvm_echo "${LTS_ALIAS}"
        fi
      } &
    done
    wait
  ) | sort
  return
}

nvm_alias() {
  local ALIAS
  ALIAS="${1-}"
  if [ -z "${ALIAS}" ]; then
    nvm_err 'An alias is required.'
    return 1
  fi
  ALIAS="$(nvm_normalize_lts "${ALIAS}")"

  if [ -z "${ALIAS}" ]; then
    return 2
  fi

  local NVM_ALIAS_PATH
  NVM_ALIAS_PATH="$(nvm_alias_path)/${ALIAS}"
  if [ ! -f "${NVM_ALIAS_PATH}" ]; then
    nvm_err 'Alias does not exist.'
    return 2
  fi

  command cat "${NVM_ALIAS_PATH}"
}

nvm_ls_current() {
  local NVM_LS_CURRENT_NODE_PATH
  if ! NVM_LS_CURRENT_NODE_PATH="$(command which node 2>/dev/null)"; then
    nvm_echo 'none'
  elif nvm_tree_contains_path "$(nvm_version_dir iojs)" "${NVM_LS_CURRENT_NODE_PATH}"; then
    nvm_add_iojs_prefix "$(iojs --version 2>/dev/null)"
  elif nvm_tree_contains_path "${NVM_DIR}" "${NVM_LS_CURRENT_NODE_PATH}"; then
    local VERSION
    VERSION="$(node --version 2>/dev/null)"
    if [ "${VERSION}" = "v0.6.21-pre" ]; then
      nvm_echo 'v0.6.21'
    else
      nvm_echo "${VERSION}"
    fi
  else
    nvm_echo 'system'
  fi
}

nvm_resolve_alias() {
  if [ -z "${1-}" ]; then
    return 1
  fi

  local PATTERN
  PATTERN="${1-}"

  local ALIAS
  ALIAS="${PATTERN}"
  local ALIAS_TEMP

  local SEEN_ALIASES
  SEEN_ALIASES="${ALIAS}"
  while true; do
    ALIAS_TEMP="$(nvm_alias "${ALIAS}" 2>/dev/null || nvm_echo)"

    if [ -z "${ALIAS_TEMP}" ]; then
      break
    fi

    if command printf "${SEEN_ALIASES}" | nvm_grep -q -e "^${ALIAS_TEMP}$"; then
      ALIAS="∞"
      break
    fi

    SEEN_ALIASES="${SEEN_ALIASES}\\n${ALIAS_TEMP}"
    ALIAS="${ALIAS_TEMP}"
  done

  if [ -n "${ALIAS}" ] && [ "_${ALIAS}" != "_${PATTERN}" ]; then
    local NVM_IOJS_PREFIX
    NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
    local NVM_NODE_PREFIX
    NVM_NODE_PREFIX="$(nvm_node_prefix)"
    case "${ALIAS}" in
      '∞' | \
      "${NVM_IOJS_PREFIX}" | "${NVM_IOJS_PREFIX}-" | \
      "${NVM_NODE_PREFIX}")
        nvm_echo "${ALIAS}"
      ;;
      *)
        nvm_ensure_version_prefix "${ALIAS}"
      ;;
    esac
    return 0
  fi

  if nvm_validate_implicit_alias "${PATTERN}" 2>/dev/null; then
    local IMPLICIT
    IMPLICIT="$(nvm_print_implicit_alias local "${PATTERN}" 2>/dev/null)"
    if [ -n "${IMPLICIT}" ]; then
      nvm_ensure_version_prefix "${IMPLICIT}"
    fi
  fi

  return 2
}

nvm_resolve_local_alias() {
  if [ -z "${1-}" ]; then
    return 1
  fi

  local VERSION
  local EXIT_CODE
  VERSION="$(nvm_resolve_alias "${1-}")"
  EXIT_CODE=$?
  if [ -z "${VERSION}" ]; then
    return $EXIT_CODE
  fi
  if [ "_${VERSION}" != '_∞' ]; then
    nvm_version "${VERSION}"
  else
    nvm_echo "${VERSION}"
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
  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  if [ "${1-}" = "${NVM_IOJS_PREFIX}" ]; then
    nvm_echo
  else
    nvm_echo "${1#"${NVM_IOJS_PREFIX}"-}"
  fi
}

nvm_ls() {
  local PATTERN
  PATTERN="${1-}"
  local VERSIONS
  VERSIONS=''
  if [ "${PATTERN}" = 'current' ]; then
    nvm_ls_current
    return
  fi

  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"
  local NVM_VERSION_DIR_IOJS
  NVM_VERSION_DIR_IOJS="$(nvm_version_dir "${NVM_IOJS_PREFIX}")"
  local NVM_VERSION_DIR_NEW
  NVM_VERSION_DIR_NEW="$(nvm_version_dir new)"
  local NVM_VERSION_DIR_OLD
  NVM_VERSION_DIR_OLD="$(nvm_version_dir old)"

  case "${PATTERN}" in
    "${NVM_IOJS_PREFIX}" | "${NVM_NODE_PREFIX}")
      PATTERN="${PATTERN}-"
    ;;
    *)
      if nvm_resolve_local_alias "${PATTERN}"; then
        return
      fi
      PATTERN="$(nvm_ensure_version_prefix "${PATTERN}")"
    ;;
  esac
  if [ "${PATTERN}" = 'N/A' ]; then
    return
  fi
  # If it looks like an explicit version, don't do anything funny
  local NVM_PATTERN_STARTS_WITH_V
  case $PATTERN in
    v*) NVM_PATTERN_STARTS_WITH_V=true ;;
    *) NVM_PATTERN_STARTS_WITH_V=false ;;
  esac
  if [ $NVM_PATTERN_STARTS_WITH_V = true ] && [ "_$(nvm_num_version_groups "${PATTERN}")" = "_3" ]; then
    if nvm_is_version_installed "${PATTERN}"; then
      VERSIONS="${PATTERN}"
    elif nvm_is_version_installed "$(nvm_add_iojs_prefix "${PATTERN}")"; then
      VERSIONS="$(nvm_add_iojs_prefix "${PATTERN}")"
    fi
  else
    case "${PATTERN}" in
      "${NVM_IOJS_PREFIX}-" | "${NVM_NODE_PREFIX}-" | "system") ;;
      *)
        local NUM_VERSION_GROUPS
        NUM_VERSION_GROUPS="$(nvm_num_version_groups "${PATTERN}")"
        if [ "${NUM_VERSION_GROUPS}" = "2" ] || [ "${NUM_VERSION_GROUPS}" = "1" ]; then
          PATTERN="${PATTERN%.}."
        fi
      ;;
    esac

    nvm_is_zsh && setopt local_options shwordsplit
    nvm_is_zsh && unsetopt local_options markdirs

    local NVM_DIRS_TO_SEARCH1
    NVM_DIRS_TO_SEARCH1=''
    local NVM_DIRS_TO_SEARCH2
    NVM_DIRS_TO_SEARCH2=''
    local NVM_DIRS_TO_SEARCH3
    NVM_DIRS_TO_SEARCH3=''
    local NVM_ADD_SYSTEM
    NVM_ADD_SYSTEM=false
    if nvm_is_iojs_version "${PATTERN}"; then
      NVM_DIRS_TO_SEARCH1="${NVM_VERSION_DIR_IOJS}"
      PATTERN="$(nvm_strip_iojs_prefix "${PATTERN}")"
      if nvm_has_system_iojs; then
        NVM_ADD_SYSTEM=true
      fi
    elif [ "${PATTERN}" = "${NVM_NODE_PREFIX}-" ]; then
      NVM_DIRS_TO_SEARCH1="${NVM_VERSION_DIR_OLD}"
      NVM_DIRS_TO_SEARCH2="${NVM_VERSION_DIR_NEW}"
      PATTERN=''
      if nvm_has_system_node; then
        NVM_ADD_SYSTEM=true
      fi
    else
      NVM_DIRS_TO_SEARCH1="${NVM_VERSION_DIR_OLD}"
      NVM_DIRS_TO_SEARCH2="${NVM_VERSION_DIR_NEW}"
      NVM_DIRS_TO_SEARCH3="${NVM_VERSION_DIR_IOJS}"
      if nvm_has_system_iojs || nvm_has_system_node; then
        NVM_ADD_SYSTEM=true
      fi
    fi

    if ! [ -d "${NVM_DIRS_TO_SEARCH1}" ] || ! (command ls -1qA "${NVM_DIRS_TO_SEARCH1}" | nvm_grep -q .); then
      NVM_DIRS_TO_SEARCH1=''
    fi
    if ! [ -d "${NVM_DIRS_TO_SEARCH2}" ] || ! (command ls -1qA "${NVM_DIRS_TO_SEARCH2}" | nvm_grep -q .); then
      NVM_DIRS_TO_SEARCH2="${NVM_DIRS_TO_SEARCH1}"
    fi
    if ! [ -d "${NVM_DIRS_TO_SEARCH3}" ] || ! (command ls -1qA "${NVM_DIRS_TO_SEARCH3}" | nvm_grep -q .); then
      NVM_DIRS_TO_SEARCH3="${NVM_DIRS_TO_SEARCH2}"
    fi

    local SEARCH_PATTERN
    if [ -z "${PATTERN}" ]; then
      PATTERN='v'
      SEARCH_PATTERN='.*'
    else
      SEARCH_PATTERN="$(nvm_echo "${PATTERN}" | command sed 's#\.#\\\.#g;')"
    fi
    if [ -n "${NVM_DIRS_TO_SEARCH1}${NVM_DIRS_TO_SEARCH2}${NVM_DIRS_TO_SEARCH3}" ]; then
      VERSIONS="$(command find "${NVM_DIRS_TO_SEARCH1}"/* "${NVM_DIRS_TO_SEARCH2}"/* "${NVM_DIRS_TO_SEARCH3}"/* -name . -o -type d -prune -o -path "${PATTERN}*" \
        | command sed -e "
            s#${NVM_VERSION_DIR_IOJS}/#versions/${NVM_IOJS_PREFIX}/#;
            s#^${NVM_DIR}/##;
            \\#^[^v]# d;
            \\#^versions\$# d;
            s#^versions/##;
            s#^v#${NVM_NODE_PREFIX}/v#;
            \\#${SEARCH_PATTERN}# !d;
          " \
          -e 's#^\([^/]\{1,\}\)/\(.*\)$#\2.\1#;' \
        | command sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n \
        | command sed -e 's#\(.*\)\.\([^\.]\{1,\}\)$#\2-\1#;' \
                      -e "s#^${NVM_NODE_PREFIX}-##;" \
      )"
    fi
  fi

  if [ "${NVM_ADD_SYSTEM-}" = true ]; then
    if [ -z "${PATTERN}" ] || [ "${PATTERN}" = 'v' ]; then
      VERSIONS="${VERSIONS}$(command printf '\n%s' 'system')"
    elif [ "${PATTERN}" = 'system' ]; then
      VERSIONS="$(command printf '%s' 'system')"
    fi
  fi

  if [ -z "${VERSIONS}" ]; then
    nvm_echo 'N/A'
    return 3
  fi

  nvm_echo "${VERSIONS}"
}

nvm_ls_remote() {
  local PATTERN
  PATTERN="${1-}"
  if nvm_validate_implicit_alias "${PATTERN}" 2>/dev/null ; then
    local IMPLICIT
    IMPLICIT="$(nvm_print_implicit_alias remote "${PATTERN}")"
    if [ -z "${IMPLICIT-}" ] || [ "${IMPLICIT}" = 'N/A' ]; then
      nvm_echo "N/A"
      return 3
    fi
    PATTERN="$(NVM_LTS="${NVM_LTS-}" nvm_ls_remote "${IMPLICIT}" | command tail -1 | command awk '{ print $1 }')"
  elif [ -n "${PATTERN}" ]; then
    PATTERN="$(nvm_ensure_version_prefix "${PATTERN}")"
  else
    PATTERN=".*"
  fi
  NVM_LTS="${NVM_LTS-}" nvm_ls_remote_index_tab node std "${PATTERN}"
}

nvm_ls_remote_iojs() {
  NVM_LTS="${NVM_LTS-}" nvm_ls_remote_index_tab iojs std "${1-}"
}

# args flavor, type, version
nvm_ls_remote_index_tab() {
  local LTS
  LTS="${NVM_LTS-}"
  if [ "$#" -lt 3 ]; then
    nvm_err 'not enough arguments'
    return 5
  fi

  local FLAVOR
  FLAVOR="${1-}"

  local TYPE
  TYPE="${2-}"

  local MIRROR
  MIRROR="$(nvm_get_mirror "${FLAVOR}" "${TYPE}")"
  if [ -z "${MIRROR}" ]; then
    return 3
  fi

  local PREFIX
  PREFIX=''
  case "${FLAVOR}-${TYPE}" in
    iojs-std) PREFIX="$(nvm_iojs_prefix)-" ;;
    node-std) PREFIX='' ;;
    iojs-*)
      nvm_err 'unknown type of io.js release'
      return 4
    ;;
    *)
      nvm_err 'unknown type of node.js release'
      return 4
    ;;
  esac
  local SORT_COMMAND
  SORT_COMMAND='command sort'
  case "${FLAVOR}" in
    node) SORT_COMMAND='command sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n' ;;
  esac

  local PATTERN
  PATTERN="${3-}"

  if [ "${PATTERN#"${PATTERN%?}"}" = '.' ]; then
    PATTERN="${PATTERN%.}"
  fi

  local VERSIONS
  if [ -n "${PATTERN}" ] && [ "${PATTERN}" != '*' ]; then
    if [ "${FLAVOR}" = 'iojs' ]; then
      PATTERN="$(nvm_ensure_version_prefix "$(nvm_strip_iojs_prefix "${PATTERN}")")"
    else
      PATTERN="$(nvm_ensure_version_prefix "${PATTERN}")"
    fi
  else
    unset PATTERN
  fi

  nvm_is_zsh && setopt local_options shwordsplit
  local VERSION_LIST
  VERSION_LIST="$(nvm_download -L -s "${MIRROR}/index.tab" -o - \
    | command sed "
        1d;
        s/^/${PREFIX}/;
      " \
  )"
  local LTS_ALIAS
  local LTS_VERSION
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
    | while read -r LTS_ALIAS_LINE; do
      LTS_ALIAS="${LTS_ALIAS_LINE%% *}"
      LTS_VERSION="${LTS_ALIAS_LINE#* }"
      nvm_make_alias "${LTS_ALIAS}" "${LTS_VERSION}" >/dev/null 2>&1
    done; } << EOF
$VERSION_LIST
EOF

  if [ -n "${LTS-}" ]; then
    LTS="$(nvm_normalize_lts "lts/${LTS}")"
    LTS="${LTS#lts/}"
  fi

  VERSIONS="$({ command awk -v lts="${LTS-}" '{
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
    | nvm_grep -w "${PATTERN:-.*}" \
    | $SORT_COMMAND; } << EOF
$VERSION_LIST
EOF
)"
  if [ -z "${VERSIONS}" ]; then
    nvm_echo 'N/A'
    return 3
  fi
  nvm_echo "${VERSIONS}"
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
  local NVM_CHECKSUM_BIN
  NVM_CHECKSUM_BIN="$(nvm_get_checksum_binary 2>/dev/null)"
  case "${NVM_CHECKSUM_BIN-}" in
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
  local FILE
  FILE="${1-}"
  if [ -z "${FILE}" ]; then
    nvm_err 'Provided file to checksum is empty.'
    return 2
  elif ! [ -f "${FILE}" ]; then
    nvm_err 'Provided file to checksum does not exist.'
    return 1
  fi

  if nvm_has_non_aliased "sha256sum"; then
    nvm_err 'Computing checksum with sha256sum'
    command sha256sum "${FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "shasum"; then
    nvm_err 'Computing checksum with shasum -a 256'
    command shasum -a 256 "${FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "sha256"; then
    nvm_err 'Computing checksum with sha256 -q'
    command sha256 -q "${FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "gsha256sum"; then
    nvm_err 'Computing checksum with gsha256sum'
    command gsha256sum "${FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "openssl"; then
    nvm_err 'Computing checksum with openssl dgst -sha256'
    command openssl dgst -sha256 "${FILE}" | command awk '{print $NF}'
  elif nvm_has_non_aliased "bssl"; then
    nvm_err 'Computing checksum with bssl sha256sum'
    command bssl sha256sum "${FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "sha1sum"; then
    nvm_err 'Computing checksum with sha1sum'
    command sha1sum "${FILE}" | command awk '{print $1}'
  elif nvm_has_non_aliased "sha1"; then
    nvm_err 'Computing checksum with sha1 -q'
    command sha1 -q "${FILE}"
  fi
}

nvm_compare_checksum() {
  local FILE
  FILE="${1-}"
  if [ -z "${FILE}" ]; then
    nvm_err 'Provided file to checksum is empty.'
    return 4
  elif ! [ -f "${FILE}" ]; then
    nvm_err 'Provided file to checksum does not exist.'
    return 3
  fi

  local COMPUTED_SUM
  COMPUTED_SUM="$(nvm_compute_checksum "${FILE}")"

  local CHECKSUM
  CHECKSUM="${2-}"
  if [ -z "${CHECKSUM}" ]; then
    nvm_err 'Provided checksum to compare to is empty.'
    return 2
  fi

  if [ -z "${COMPUTED_SUM}" ]; then
    nvm_err "Computed checksum of '${FILE}' is empty." # missing in raspberry pi binary
    nvm_err 'WARNING: Continuing *without checksum verification*'
    return
  elif [ "${COMPUTED_SUM}" != "${CHECKSUM}" ]; then
    nvm_err "Checksums do not match: '${COMPUTED_SUM}' found, '${CHECKSUM}' expected."
    return 1
  fi
  nvm_err 'Checksums matched!'
}

# args: flavor, type, version, slug, compression
nvm_get_checksum() {
  local FLAVOR
  case "${1-}" in
    node | iojs) FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 2
    ;;
  esac

  local MIRROR
  MIRROR="$(nvm_get_mirror "${FLAVOR}" "${2-}")"
  if [ -z "${MIRROR}" ]; then
    return 1
  fi

  local SHASUMS_URL
  if [ "$(nvm_get_checksum_alg)" = 'sha-256' ]; then
    SHASUMS_URL="${MIRROR}/${3}/SHASUMS256.txt"
  else
    SHASUMS_URL="${MIRROR}/${3}/SHASUMS.txt"
  fi

  nvm_download -L -s "${SHASUMS_URL}" -o - | command awk "{ if (\"${4}.${5}\" == \$2) print \$1}"
}

nvm_print_versions() {
  local VERSION
  local LTS
  local FORMAT
  local NVM_CURRENT
  local NVM_LATEST_LTS_COLOR
  local NVM_OLD_LTS_COLOR

  local INSTALLED_COLOR
  local SYSTEM_COLOR
  local CURRENT_COLOR
  local NOT_INSTALLED_COLOR
  local DEFAULT_COLOR
  local LTS_COLOR

  INSTALLED_COLOR=$(nvm_get_colors 1)
  SYSTEM_COLOR=$(nvm_get_colors 2)
  CURRENT_COLOR=$(nvm_get_colors 3)
  NOT_INSTALLED_COLOR=$(nvm_get_colors 4)
  DEFAULT_COLOR=$(nvm_get_colors 5)
  LTS_COLOR=$(nvm_get_colors 6)

  NVM_CURRENT=$(nvm_ls_current)
  NVM_LATEST_LTS_COLOR=$(nvm_echo "${CURRENT_COLOR}" | command tr '0;' '1;')
  NVM_OLD_LTS_COLOR="${DEFAULT_COLOR}"
  local NVM_HAS_COLORS
  if [ -z "${NVM_NO_COLORS-}" ] && nvm_has_colors; then
    NVM_HAS_COLORS=1
  fi
  local LTS_LENGTH
  local LTS_FORMAT
  nvm_echo "${1-}" \
  | command sed '1!G;h;$!d' \
  | command awk '{ if ($2 && $3 && $3 == "*") { print $1, "(Latest LTS: " $2 ")" } else if ($2) { print $1, "(LTS: " $2 ")" } else { print $1 } }' \
  | command sed '1!G;h;$!d' \
  | while read -r VERSION_LINE; do
    VERSION="${VERSION_LINE%% *}"
    LTS="${VERSION_LINE#* }"
    FORMAT='%15s'
    if [ "_${VERSION}" = "_${NVM_CURRENT}" ]; then
      if [ "${NVM_HAS_COLORS-}" = '1' ]; then
        FORMAT="\033[${CURRENT_COLOR}-> %12s\033[0m"
      else
        FORMAT='-> %12s *'
      fi
    elif [ "${VERSION}" = "system" ]; then
      if [ "${NVM_HAS_COLORS-}" = '1' ]; then
        FORMAT="\033[${SYSTEM_COLOR}%15s\033[0m"
      else
        FORMAT='%15s *'
      fi
    elif nvm_is_version_installed "${VERSION}"; then
      if [ "${NVM_HAS_COLORS-}" = '1' ]; then
        FORMAT="\033[${INSTALLED_COLOR}%15s\033[0m"
      else
        FORMAT='%15s *'
      fi
    fi
    if [ "${LTS}" != "${VERSION}" ]; then
      case "${LTS}" in
        *Latest*)
          LTS="${LTS##Latest }"
          LTS_LENGTH="${#LTS}"
          if [ "${NVM_HAS_COLORS-}" = '1' ]; then
            LTS_FORMAT="  \\033[${NVM_LATEST_LTS_COLOR}%${LTS_LENGTH}s\\033[0m"
          else
            LTS_FORMAT="  %${LTS_LENGTH}s"
          fi
        ;;
        *)
          LTS_LENGTH="${#LTS}"
          if [ "${NVM_HAS_COLORS-}" = '1' ]; then
            LTS_FORMAT="  \\033[${NVM_OLD_LTS_COLOR}%${LTS_LENGTH}s\\033[0m"
          else
            LTS_FORMAT="  %${LTS_LENGTH}s"
          fi
        ;;
      esac
      command printf -- "${FORMAT}${LTS_FORMAT}\\n" "${VERSION}" " ${LTS}"
    else
      command printf -- "${FORMAT}\\n" "${VERSION}"
    fi
  done
}

nvm_validate_implicit_alias() {
  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"

  case "$1" in
    "stable" | "unstable" | "${NVM_IOJS_PREFIX}" | "${NVM_NODE_PREFIX}")
      return
    ;;
    *)
      nvm_err "Only implicit aliases 'stable', 'unstable', '${NVM_IOJS_PREFIX}', and '${NVM_NODE_PREFIX}' are supported."
      return 1
    ;;
  esac
}

nvm_print_implicit_alias() {
  if [ "_$1" != "_local" ] && [ "_$1" != "_remote" ]; then
    nvm_err "nvm_print_implicit_alias must be specified with local or remote as the first argument."
    return 1
  fi

  local NVM_IMPLICIT
  NVM_IMPLICIT="$2"
  if ! nvm_validate_implicit_alias "${NVM_IMPLICIT}"; then
    return 2
  fi

  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"
  local NVM_COMMAND
  local NVM_ADD_PREFIX_COMMAND
  local LAST_TWO
  case "${NVM_IMPLICIT}" in
    "${NVM_IOJS_PREFIX}")
      NVM_COMMAND="nvm_ls_remote_iojs"
      NVM_ADD_PREFIX_COMMAND="nvm_add_iojs_prefix"
      if [ "_$1" = "_local" ]; then
        NVM_COMMAND="nvm_ls ${NVM_IMPLICIT}"
      fi

      nvm_is_zsh && setopt local_options shwordsplit

      local NVM_IOJS_VERSION
      local EXIT_CODE
      NVM_IOJS_VERSION="$(${NVM_COMMAND})" &&:
      EXIT_CODE="$?"
      if [ "_${EXIT_CODE}" = "_0" ]; then
        NVM_IOJS_VERSION="$(nvm_echo "${NVM_IOJS_VERSION}" | command sed "s/^${NVM_IMPLICIT}-//" | nvm_grep -e '^v' | command cut -c2- | command cut -d . -f 1,2 | uniq | command tail -1)"
      fi

      if [ "_$NVM_IOJS_VERSION" = "_N/A" ]; then
        nvm_echo 'N/A'
      else
        ${NVM_ADD_PREFIX_COMMAND} "${NVM_IOJS_VERSION}"
      fi
      return $EXIT_CODE
    ;;
    "${NVM_NODE_PREFIX}")
      nvm_echo 'stable'
      return
    ;;
    *)
      NVM_COMMAND="nvm_ls_remote"
      if [ "_$1" = "_local" ]; then
        NVM_COMMAND="nvm_ls node"
      fi

      nvm_is_zsh && setopt local_options shwordsplit

      LAST_TWO=$($NVM_COMMAND | nvm_grep -e '^v' | command cut -c2- | command cut -d . -f 1,2 | uniq)
    ;;
  esac
  local MINOR
  local STABLE
  local UNSTABLE
  local MOD
  local NORMALIZED_VERSION

  nvm_is_zsh && setopt local_options shwordsplit
  for MINOR in $LAST_TWO; do
    NORMALIZED_VERSION="$(nvm_normalize_version "$MINOR")"
    if [ "_0${NORMALIZED_VERSION#?}" != "_$NORMALIZED_VERSION" ]; then
      STABLE="$MINOR"
    else
      MOD="$(awk 'BEGIN { print int(ARGV[1] / 1000000) % 2 ; exit(0) }' "${NORMALIZED_VERSION}")"
      if [ "${MOD}" -eq 0 ]; then
        STABLE="${MINOR}"
      elif [ "${MOD}" -eq 1 ]; then
        UNSTABLE="${MINOR}"
      fi
    fi
  done

  if [ "_$2" = '_stable' ]; then
    nvm_echo "${STABLE}"
  elif [ "_$2" = '_unstable' ]; then
    nvm_echo "${UNSTABLE:-"N/A"}"
  fi
}

nvm_get_os() {
  local NVM_UNAME
  NVM_UNAME="$(command uname -a)"
  local NVM_OS
  case "${NVM_UNAME}" in
    Linux\ *) NVM_OS=linux ;;
    Darwin\ *) NVM_OS=darwin ;;
    SunOS\ *) NVM_OS=sunos ;;
    FreeBSD\ *) NVM_OS=freebsd ;;
    OpenBSD\ *) NVM_OS=openbsd ;;
    AIX\ *) NVM_OS=aix ;;
    CYGWIN* | MSYS* | MINGW*) NVM_OS=win ;;
  esac
  nvm_echo "${NVM_OS-}"
}

nvm_get_arch() {
  local HOST_ARCH
  local NVM_OS
  local EXIT_CODE

  NVM_OS="$(nvm_get_os)"
  # If the OS is SunOS, first try to use pkgsrc to guess
  # the most appropriate arch. If it's not available, use
  # isainfo to get the instruction set supported by the
  # kernel.
  if [ "_${NVM_OS}" = "_sunos" ]; then
    if HOST_ARCH=$(pkg_info -Q MACHINE_ARCH pkg_install); then
      HOST_ARCH=$(nvm_echo "${HOST_ARCH}" | command tail -1)
    else
      HOST_ARCH=$(isainfo -n)
    fi
  elif [ "_${NVM_OS}" = "_aix" ]; then
    HOST_ARCH=ppc64
  else
    HOST_ARCH="$(command uname -m)"
  fi

  local NVM_ARCH
  case "${HOST_ARCH}" in
    x86_64 | amd64) NVM_ARCH="x64" ;;
    i*86) NVM_ARCH="x86" ;;
    aarch64) NVM_ARCH="arm64" ;;
    *) NVM_ARCH="${HOST_ARCH}" ;;
  esac

  # If running a 64bit ARM kernel but a 32bit ARM userland, change ARCH to 32bit ARM (armv7l)
  L=$(ls -dl /sbin/init 2>/dev/null) # if /sbin/init is 32bit executable
  if [ "$(uname)" = "Linux" ] && [ "${NVM_ARCH}" = arm64 ] && [ "$(od -An -t x1 -j 4 -N 1 "${L#*-> }")" = ' 01' ]; then
    NVM_ARCH=armv7l
    HOST_ARCH=armv7l
  fi

  nvm_echo "${NVM_ARCH}"
}

nvm_get_minor_version() {
  local VERSION
  VERSION="$1"

  if [ -z "${VERSION}" ]; then
    nvm_err 'a version is required'
    return 1
  fi

  case "${VERSION}" in
    v | .* | *..* | v*[!.0123456789]* | [!v]*[!.0123456789]* | [!v0123456789]* | v[!0123456789]*)
      nvm_err 'invalid version number'
      return 2
    ;;
  esac

  local PREFIXED_VERSION
  PREFIXED_VERSION="$(nvm_format_version "${VERSION}")"

  local MINOR
  MINOR="$(nvm_echo "${PREFIXED_VERSION}" | nvm_grep -e '^v' | command cut -c2- | command cut -d . -f 1,2)"
  if [ -z "${MINOR}" ]; then
    nvm_err 'invalid version number! (please report this)'
    return 3
  fi
  nvm_echo "${MINOR}"
}

nvm_ensure_default_set() {
  local VERSION
  VERSION="$1"
  if [ -z "${VERSION}" ]; then
    nvm_err 'nvm_ensure_default_set: a version is required'
    return 1
  elif nvm_alias default >/dev/null 2>&1; then
    # default already set
    return 0
  fi
  local OUTPUT
  OUTPUT="$(nvm alias default "${VERSION}")"
  local EXIT_CODE
  EXIT_CODE="$?"
  nvm_echo "Creating default alias: ${OUTPUT}"
  return $EXIT_CODE
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

  local NVM_OS
  local PREFIXED_VERSION
  local VERSION
  local TARBALL
  local TMPDIR
  NVM_OS="${1}"
  PREFIXED_VERSION="${2}"
  VERSION="${3}"
  TARBALL="${4}"
  TMPDIR="${5}"

  local VERSION_PATH

  [ -n "${TMPDIR-}" ] && \
  command mkdir -p "${TMPDIR}" && \
  VERSION_PATH="$(nvm_version_path "${PREFIXED_VERSION}")" || return 1

  # For Windows system (GitBash with MSYS, Cygwin)
  if [ "${NVM_OS}" = 'win' ]; then
    VERSION_PATH="${VERSION_PATH}/bin"
    command unzip -q "${TARBALL}" -d "${TMPDIR}" || return 1
  # For non Windows system (including WSL running on Windows)
  else
    local tar_compression_flag
    tar_compression_flag='z'
    if nvm_supports_xz "${VERSION}"; then
      tar_compression_flag='J'
    fi

    local tar
    if [ "${NVM_OS}" = 'aix' ]; then
      tar='gtar'
    else
      tar='tar'
    fi
    command "${tar}" -x${tar_compression_flag}f "${TARBALL}" -C "${TMPDIR}" --strip-components 1 || return 1
  fi

  command mkdir -p "${VERSION_PATH}" || return 1

  if [ "${NVM_OS}" = 'win' ]; then
    command mv "${TMPDIR}/"*/* "${VERSION_PATH}" || return 1
    command chmod +x "${VERSION_PATH}"/node.exe || return 1
    command chmod +x "${VERSION_PATH}"/npm || return 1
    command chmod +x "${VERSION_PATH}"/npx 2>/dev/null
  else
    command mv "${TMPDIR}/"* "${VERSION_PATH}" || return 1
  fi

  command rm -rf "${TMPDIR}"

  return 0
}

# args: flavor, type, version, reinstall
nvm_install_binary() {
  local FLAVOR
  case "${1-}" in
    node | iojs) FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 4
    ;;
  esac

  local TYPE
  TYPE="${2-}"

  local PREFIXED_VERSION
  PREFIXED_VERSION="${3-}"
  if [ -z "${PREFIXED_VERSION}" ]; then
    nvm_err 'A version number is required.'
    return 3
  fi

  local nosource
  nosource="${4-}"

  local VERSION
  VERSION="$(nvm_strip_iojs_prefix "${PREFIXED_VERSION}")"

  local NVM_OS
  NVM_OS="$(nvm_get_os)"

  if [ -z "${NVM_OS}" ]; then
    return 2
  fi

  local TARBALL
  local TMPDIR

  local PROGRESS_BAR
  local NODE_OR_IOJS
  if [ "${FLAVOR}" = 'node' ]; then
    NODE_OR_IOJS="${FLAVOR}"
  elif [ "${FLAVOR}" = 'iojs' ]; then
    NODE_OR_IOJS="io.js"
  fi
  if [ "${NVM_NO_PROGRESS-}" = "1" ]; then
    # --silent, --show-error, use short option as @samrocketman mentions the compatibility issue.
    PROGRESS_BAR="-sS"
  else
    PROGRESS_BAR="--progress-bar"
  fi
  nvm_echo "Downloading and installing ${NODE_OR_IOJS-} ${VERSION}..."
  TARBALL="$(PROGRESS_BAR="${PROGRESS_BAR}" nvm_download_artifact "${FLAVOR}" binary "${TYPE-}" "${VERSION}" | command tail -1)"
  if [ -f "${TARBALL}" ]; then
    TMPDIR="$(dirname "${TARBALL}")/files"
  fi

  if nvm_install_binary_extract "${NVM_OS}" "${PREFIXED_VERSION}" "${VERSION}" "${TARBALL}" "${TMPDIR}"; then
    if [ -n "${ALIAS-}" ]; then
      nvm alias "${ALIAS}" "${provided_version}"
    fi
    return 0
  fi


  # Read nosource from arguments
  if [ "${nosource-}" = '1' ]; then
      nvm_err 'Binary download failed. Download from source aborted.'
      return 0
  fi

  nvm_err 'Binary download failed, trying source.'
  if [ -n "${TMPDIR-}" ]; then
    command rm -rf "${TMPDIR}"
  fi
  return 1
}

# args: flavor, kind, version
nvm_get_download_slug() {
  local FLAVOR
  case "${1-}" in
    node | iojs) FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 1
    ;;
  esac

  local KIND
  case "${2-}" in
    binary | source) KIND="${2}" ;;
    *)
      nvm_err 'supported kinds: binary, source'
      return 2
    ;;
  esac

  local VERSION
  VERSION="${3-}"

  local NVM_OS
  NVM_OS="$(nvm_get_os)"

  local NVM_ARCH
  NVM_ARCH="$(nvm_get_arch)"
  if ! nvm_is_merged_node_version "${VERSION}"; then
    if [ "${NVM_ARCH}" = 'armv6l' ] || [ "${NVM_ARCH}" = 'armv7l' ]; then
      NVM_ARCH="arm-pi"
    fi
  fi

  # If node version in below 16.0.0 then there is no arm64 packages available in node repositories, so we have to install "x64" arch packages
  # If running MAC M1 :: arm64 arch and Darwin OS then use "x64" Architecture because node doesn't provide darwin_arm64 package below v16.0.0
  if nvm_version_greater '16.0.0' "${VERSION}"; then
    if [ "_${NVM_OS}" = '_darwin' ] && [ "${NVM_ARCH}" = 'arm64' ]; then
      NVM_ARCH=x64
    fi
  fi

  if [ "${KIND}" = 'binary' ]; then
    nvm_echo "${FLAVOR}-${VERSION}-${NVM_OS}-${NVM_ARCH}"
  elif [ "${KIND}" = 'source' ]; then
    nvm_echo "${FLAVOR}-${VERSION}"
  fi
}

nvm_get_artifact_compression() {
  local VERSION
  VERSION="${1-}"

  local NVM_OS
  NVM_OS="$(nvm_get_os)"

  local COMPRESSION
  COMPRESSION='tar.gz'
  if [ "_${NVM_OS}" = '_win' ]; then
    COMPRESSION='zip'
  elif nvm_supports_xz "${VERSION}"; then
    COMPRESSION='tar.xz'
  fi

  nvm_echo "${COMPRESSION}"
}

# args: flavor, kind, type, version
nvm_download_artifact() {
  local FLAVOR
  case "${1-}" in
    node | iojs) FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 1
    ;;
  esac

  local KIND
  case "${2-}" in
    binary | source) KIND="${2}" ;;
    *)
      nvm_err 'supported kinds: binary, source'
      return 1
    ;;
  esac

  local TYPE
  TYPE="${3-}"

  local MIRROR
  MIRROR="$(nvm_get_mirror "${FLAVOR}" "${TYPE}")"
  if [ -z "${MIRROR}" ]; then
    return 2
  fi

  local VERSION
  VERSION="${4}"

  if [ -z "${VERSION}" ]; then
    nvm_err 'A version number is required.'
    return 3
  fi

  if [ "${KIND}" = 'binary' ] && ! nvm_binary_available "${VERSION}"; then
    nvm_err "No precompiled binary available for ${VERSION}."
    return
  fi

  local SLUG
  SLUG="$(nvm_get_download_slug "${FLAVOR}" "${KIND}" "${VERSION}")"

  local COMPRESSION
  COMPRESSION="$(nvm_get_artifact_compression "${VERSION}")"

  local CHECKSUM
  CHECKSUM="$(nvm_get_checksum "${FLAVOR}" "${TYPE}" "${VERSION}" "${SLUG}" "${COMPRESSION}")"

  local tmpdir
  if [ "${KIND}" = 'binary' ]; then
    tmpdir="$(nvm_cache_dir)/bin/${SLUG}"
  else
    tmpdir="$(nvm_cache_dir)/src/${SLUG}"
  fi
  command mkdir -p "${tmpdir}/files" || (
    nvm_err "creating directory ${tmpdir}/files failed"
    return 3
  )

  local TARBALL
  TARBALL="${tmpdir}/${SLUG}.${COMPRESSION}"
  local TARBALL_URL
  if nvm_version_greater_than_or_equal_to "${VERSION}" 0.1.14; then
    TARBALL_URL="${MIRROR}/${VERSION}/${SLUG}.${COMPRESSION}"
  else
    # node <= 0.1.13 does not have a directory
    TARBALL_URL="${MIRROR}/${SLUG}.${COMPRESSION}"
  fi

  if [ -r "${TARBALL}" ]; then
    nvm_err "Local cache found: $(nvm_sanitize_path "${TARBALL}")"
    if nvm_compare_checksum "${TARBALL}" "${CHECKSUM}" >/dev/null 2>&1; then
      nvm_err "Checksums match! Using existing downloaded archive $(nvm_sanitize_path "${TARBALL}")"
      nvm_echo "${TARBALL}"
      return 0
    fi
    nvm_compare_checksum "${TARBALL}" "${CHECKSUM}"
    nvm_err "Checksum check failed!"
    nvm_err "Removing the broken local cache..."
    command rm -rf "${TARBALL}"
  fi
  nvm_err "Downloading ${TARBALL_URL}..."
  nvm_download -L -C - "${PROGRESS_BAR}" "${TARBALL_URL}" -o "${TARBALL}" || (
    command rm -rf "${TARBALL}" "${tmpdir}"
    nvm_err "Binary download from ${TARBALL_URL} failed, trying source."
    return 4
  )

  if nvm_grep '404 Not Found' "${TARBALL}" >/dev/null; then
    command rm -rf "${TARBALL}" "${tmpdir}"
    nvm_err "HTTP 404 at URL ${TARBALL_URL}"
    return 5
  fi

  nvm_compare_checksum "${TARBALL}" "${CHECKSUM}" || (
    command rm -rf "${tmpdir}/files"
    return 6
  )

  nvm_echo "${TARBALL}"
}

nvm_get_make_jobs() {
  if nvm_is_natural_num "${1-}"; then
    NVM_MAKE_JOBS="$1"
    nvm_echo "number of \`make\` jobs: ${NVM_MAKE_JOBS}"
    return
  elif [ -n "${1-}" ]; then
    unset NVM_MAKE_JOBS
    nvm_err "$1 is invalid for number of \`make\` jobs, must be a natural number"
  fi
  local NVM_OS
  NVM_OS="$(nvm_get_os)"
  local NVM_CPU_CORES
  case "_${NVM_OS}" in
    "_linux")
      NVM_CPU_CORES="$(nvm_grep -c -E '^processor.+: [0-9]+' /proc/cpuinfo)"
    ;;
    "_freebsd" | "_darwin" | "_openbsd")
      NVM_CPU_CORES="$(sysctl -n hw.ncpu)"
    ;;
    "_sunos")
      NVM_CPU_CORES="$(psrinfo | wc -l)"
    ;;
    "_aix")
      NVM_CPU_CORES="$(pmcycles -m | wc -l)"
    ;;
  esac
  if ! nvm_is_natural_num "${NVM_CPU_CORES}"; then
    nvm_err 'Can not determine how many core(s) are available, running in single-threaded mode.'
    nvm_err 'Please report an issue on GitHub to help us make nvm run faster on your computer!'
    NVM_MAKE_JOBS=1
  else
    nvm_echo "Detected that you have ${NVM_CPU_CORES} CPU core(s)"
    if [ "${NVM_CPU_CORES}" -gt 2 ]; then
      NVM_MAKE_JOBS=$((NVM_CPU_CORES - 1))
      nvm_echo "Running with ${NVM_MAKE_JOBS} threads to speed up the build"
    else
      NVM_MAKE_JOBS=1
      nvm_echo 'Number of CPU core(s) less than or equal to 2, running in single-threaded mode'
    fi
  fi
}

# args: flavor, type, version, make jobs, additional
nvm_install_source() {
  local FLAVOR
  case "${1-}" in
    node | iojs) FLAVOR="${1}" ;;
    *)
      nvm_err 'supported flavors: node, iojs'
      return 4
    ;;
  esac

  local TYPE
  TYPE="${2-}"

  local PREFIXED_VERSION
  PREFIXED_VERSION="${3-}"
  if [ -z "${PREFIXED_VERSION}" ]; then
    nvm_err 'A version number is required.'
    return 3
  fi

  local VERSION
  VERSION="$(nvm_strip_iojs_prefix "${PREFIXED_VERSION}")"

  local NVM_MAKE_JOBS
  NVM_MAKE_JOBS="${4-}"

  local ADDITIONAL_PARAMETERS
  ADDITIONAL_PARAMETERS="${5-}"

  local NVM_ARCH
  NVM_ARCH="$(nvm_get_arch)"
  if [ "${NVM_ARCH}" = 'armv6l' ] || [ "${NVM_ARCH}" = 'armv7l' ]; then
    if [ -n "${ADDITIONAL_PARAMETERS}" ]; then
      ADDITIONAL_PARAMETERS="--without-snapshot ${ADDITIONAL_PARAMETERS}"
    else
      ADDITIONAL_PARAMETERS='--without-snapshot'
    fi
  fi

  if [ -n "${ADDITIONAL_PARAMETERS}" ]; then
    nvm_echo "Additional options while compiling: ${ADDITIONAL_PARAMETERS}"
  fi

  local NVM_OS
  NVM_OS="$(nvm_get_os)"

  local make
  make='make'
  local MAKE_CXX
  case "${NVM_OS}" in
    'freebsd' | 'openbsd')
      make='gmake'
      MAKE_CXX="CC=${CC:-cc} CXX=${CXX:-c++}"
    ;;
    'darwin')
      MAKE_CXX="CC=${CC:-cc} CXX=${CXX:-c++}"
    ;;
    'aix')
      make='gmake'
    ;;
  esac
  if nvm_has "clang++" && nvm_has "clang" && nvm_version_greater_than_or_equal_to "$(nvm_clang_version)" 3.5; then
    if [ -z "${CC-}" ] || [ -z "${CXX-}" ]; then
      nvm_echo "Clang v3.5+ detected! CC or CXX not specified, will use Clang as C/C++ compiler!"
      MAKE_CXX="CC=${CC:-cc} CXX=${CXX:-c++}"
    fi
  fi

  local tar_compression_flag
  tar_compression_flag='z'
  if nvm_supports_xz "${VERSION}"; then
    tar_compression_flag='J'
  fi

  local tar
  tar='tar'
  if [ "${NVM_OS}" = 'aix' ]; then
    tar='gtar'
  fi

  local TARBALL
  local TMPDIR
  local VERSION_PATH

  if [ "${NVM_NO_PROGRESS-}" = "1" ]; then
    # --silent, --show-error, use short option as @samrocketman mentions the compatibility issue.
    PROGRESS_BAR="-sS"
  else
    PROGRESS_BAR="--progress-bar"
  fi

  nvm_is_zsh && setopt local_options shwordsplit

  TARBALL="$(PROGRESS_BAR="${PROGRESS_BAR}" nvm_download_artifact "${FLAVOR}" source "${TYPE}" "${VERSION}" | command tail -1)" && \
  [ -f "${TARBALL}" ] && \
  TMPDIR="$(dirname "${TARBALL}")/files" && \
  if ! (
    # shellcheck disable=SC2086
    command mkdir -p "${TMPDIR}" && \
    command "${tar}" -x${tar_compression_flag}f "${TARBALL}" -C "${TMPDIR}" --strip-components 1 && \
    VERSION_PATH="$(nvm_version_path "${PREFIXED_VERSION}")" && \
    nvm_cd "${TMPDIR}" && \
    nvm_echo '$>'./configure --prefix="${VERSION_PATH}" $ADDITIONAL_PARAMETERS'<' && \
    ./configure --prefix="${VERSION_PATH}" $ADDITIONAL_PARAMETERS && \
    $make -j "${NVM_MAKE_JOBS}" ${MAKE_CXX-} && \
    command rm -f "${VERSION_PATH}" 2>/dev/null && \
    $make -j "${NVM_MAKE_JOBS}" ${MAKE_CXX-} install
  ); then
    nvm_err "nvm: install ${VERSION} failed!"
    command rm -rf "${TMPDIR-}"
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
  local VERSION
  VERSION="$(nvm_ls_current)"
  if ! nvm_has "npm"; then
    nvm_echo 'Installing npm...'
    if nvm_version_greater 0.2.0 "${VERSION}"; then
      nvm_err 'npm requires node v0.2.3 or higher'
    elif nvm_version_greater_than_or_equal_to "${VERSION}" 0.2.0; then
      if nvm_version_greater 0.2.3 "${VERSION}"; then
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
  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local PROVIDED_VERSION
  PROVIDED_VERSION="$1"
  case "_${PROVIDED_VERSION}" in
    "_${NVM_IOJS_PREFIX}" | '_io.js')
      nvm_version "${NVM_IOJS_PREFIX}"
    ;;
    '_system')
      nvm_echo 'system'
    ;;
    *)
      nvm_version "${PROVIDED_VERSION}"
    ;;
  esac
}

nvm_npm_global_modules() {
  local NPMLIST
  local VERSION
  VERSION="$1"
  NPMLIST=$(nvm use "${VERSION}" >/dev/null && npm list -g --depth=0 2>/dev/null | command sed 1,1d | nvm_grep -v 'UNMET PEER DEPENDENCY')

  local INSTALLS
  INSTALLS=$(nvm_echo "${NPMLIST}" | command sed -e '/ -> / d' -e '/\(empty\)/ d' -e 's/^.* \(.*@[^ ]*\).*/\1/' -e '/^npm@[^ ]*.*$/ d' | command xargs)

  local LINKS
  LINKS="$(nvm_echo "${NPMLIST}" | command sed -n 's/.* -> \(.*\)/\1/ p')"

  nvm_echo "${INSTALLS} //// ${LINKS}"
}

nvm_npmrc_bad_news_bears() {
  local NVM_NPMRC
  NVM_NPMRC="${1-}"
  if [ -n "${NVM_NPMRC}" ] && [ -f "${NVM_NPMRC}" ] && nvm_grep -Ee '^(prefix|globalconfig) *=' <"${NVM_NPMRC}" >/dev/null; then
    return 0
  fi
  return 1
}

nvm_die_on_prefix() {
  local NVM_DELETE_PREFIX
  NVM_DELETE_PREFIX="${1-}"
  case "${NVM_DELETE_PREFIX}" in
    0 | 1) ;;
    *)
      nvm_err 'First argument "delete the prefix" must be zero or one'
      return 1
    ;;
  esac
  local NVM_COMMAND
  NVM_COMMAND="${2-}"
  local NVM_VERSION_DIR
  NVM_VERSION_DIR="${3-}"
  if [ -z "${NVM_COMMAND}" ] || [ -z "${NVM_VERSION_DIR}" ]; then
    nvm_err 'Second argument "nvm command", and third argument "nvm version dir", must both be nonempty'
    return 2
  fi

  # npm first looks at $PREFIX (case-sensitive)
  # we do not bother to test the value here; if this env var is set, unset it to continue.
  # however, `npm exec` in npm v7.2+ sets $PREFIX; if set, inherit it
  if [ -n "${PREFIX-}" ] && [ "$(nvm_version_path "$(node -v)")" != "${PREFIX}" ]; then
    nvm deactivate >/dev/null 2>&1
    nvm_err "nvm is not compatible with the \"PREFIX\" environment variable: currently set to \"${PREFIX}\""
    nvm_err 'Run `unset PREFIX` to unset it.'
    return 3
  fi

  local NVM_OS
  NVM_OS="$(nvm_get_os)"

  # npm normalizes NPM_CONFIG_-prefixed env vars
  # https://github.com/npm/npmconf/blob/22827e4038d6eebaafeb5c13ed2b92cf97b8fb82/npmconf.js#L331-L348
  # https://github.com/npm/npm/blob/5e426a78ca02d0044f8dd26e0c5f881217081cbd/lib/config/core.js#L343-L359
  #
  # here, we avoid trying to replicate "which one wins" or testing the value; if any are defined, it errors
  # until none are left.
  local NVM_NPM_CONFIG_x_PREFIX_ENV
  NVM_NPM_CONFIG_x_PREFIX_ENV="$(command awk 'BEGIN { for (name in ENVIRON) if (toupper(name) == "NPM_CONFIG_PREFIX") { print name; break } }')"
  if [ -n "${NVM_NPM_CONFIG_x_PREFIX_ENV-}" ]; then
    local NVM_CONFIG_VALUE
    eval "NVM_CONFIG_VALUE=\"\$${NVM_NPM_CONFIG_x_PREFIX_ENV}\""
    if [ -n "${NVM_CONFIG_VALUE-}" ] && [ "_${NVM_OS}" = "_win" ]; then
      NVM_CONFIG_VALUE="$(cd "$NVM_CONFIG_VALUE" 2>/dev/null && pwd)"
    fi
    if [ -n "${NVM_CONFIG_VALUE-}" ] && ! nvm_tree_contains_path "${NVM_DIR}" "${NVM_CONFIG_VALUE}"; then
      nvm deactivate >/dev/null 2>&1
      nvm_err "nvm is not compatible with the \"${NVM_NPM_CONFIG_x_PREFIX_ENV}\" environment variable: currently set to \"${NVM_CONFIG_VALUE}\""
      nvm_err "Run \`unset ${NVM_NPM_CONFIG_x_PREFIX_ENV}\` to unset it."
      return 4
    fi
  fi

  # here, npm config checks npmrc files.
  # the stack is: cli, env, project, user, global, builtin, defaults
  # cli does not apply; env is covered above, defaults don't exist for prefix
  # there are 4 npmrc locations to check: project, global, user, and builtin
  # project: find the closest node_modules or package.json-containing dir, `.npmrc`
  # global: default prefix + `/etc/npmrc`
  # user: $HOME/.npmrc
  # builtin: npm install location, `npmrc`
  #
  # if any of them have a `prefix`, fail.
  # if any have `globalconfig`, fail also, just in case, to avoid spidering configs.

  local NVM_NPM_BUILTIN_NPMRC
  NVM_NPM_BUILTIN_NPMRC="${NVM_VERSION_DIR}/lib/node_modules/npm/npmrc"
  if nvm_npmrc_bad_news_bears "${NVM_NPM_BUILTIN_NPMRC}"; then
    if [ "_${NVM_DELETE_PREFIX}" = "_1" ]; then
      npm config --loglevel=warn delete prefix --userconfig="${NVM_NPM_BUILTIN_NPMRC}"
      npm config --loglevel=warn delete globalconfig --userconfig="${NVM_NPM_BUILTIN_NPMRC}"
    else
      nvm_err "Your builtin npmrc file ($(nvm_sanitize_path "${NVM_NPM_BUILTIN_NPMRC}"))"
      nvm_err 'has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.'
      nvm_err "Run \`${NVM_COMMAND}\` to unset it."
      return 10
    fi
  fi

  local NVM_NPM_GLOBAL_NPMRC
  NVM_NPM_GLOBAL_NPMRC="${NVM_VERSION_DIR}/etc/npmrc"
  if nvm_npmrc_bad_news_bears "${NVM_NPM_GLOBAL_NPMRC}"; then
    if [ "_${NVM_DELETE_PREFIX}" = "_1" ]; then
      npm config --global --loglevel=warn delete prefix
      npm config --global --loglevel=warn delete globalconfig
    else
      nvm_err "Your global npmrc file ($(nvm_sanitize_path "${NVM_NPM_GLOBAL_NPMRC}"))"
      nvm_err 'has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.'
      nvm_err "Run \`${NVM_COMMAND}\` to unset it."
      return 10
    fi
  fi

  local NVM_NPM_USER_NPMRC
  NVM_NPM_USER_NPMRC="${HOME}/.npmrc"
  if nvm_npmrc_bad_news_bears "${NVM_NPM_USER_NPMRC}"; then
    if [ "_${NVM_DELETE_PREFIX}" = "_1" ]; then
      npm config --loglevel=warn delete prefix --userconfig="${NVM_NPM_USER_NPMRC}"
      npm config --loglevel=warn delete globalconfig --userconfig="${NVM_NPM_USER_NPMRC}"
    else
      nvm_err "Your user’s .npmrc file ($(nvm_sanitize_path "${NVM_NPM_USER_NPMRC}"))"
      nvm_err 'has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.'
      nvm_err "Run \`${NVM_COMMAND}\` to unset it."
      return 10
    fi
  fi

  local NVM_NPM_PROJECT_NPMRC
  NVM_NPM_PROJECT_NPMRC="$(nvm_find_project_dir)/.npmrc"
  if nvm_npmrc_bad_news_bears "${NVM_NPM_PROJECT_NPMRC}"; then
    if [ "_${NVM_DELETE_PREFIX}" = "_1" ]; then
      npm config --loglevel=warn delete prefix
      npm config --loglevel=warn delete globalconfig
    else
      nvm_err "Your project npmrc file ($(nvm_sanitize_path "${NVM_NPM_PROJECT_NPMRC}"))"
      nvm_err 'has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.'
      nvm_err "Run \`${NVM_COMMAND}\` to unset it."
      return 10
    fi
  fi
}

# Succeeds if $IOJS_VERSION represents an io.js version that has a
# Solaris binary, fails otherwise.
# Currently, only io.js 3.3.1 has a Solaris binary available, and it's the
# latest io.js version available. The expectation is that any potential io.js
# version later than v3.3.1 will also have Solaris binaries.
nvm_iojs_version_has_solaris_binary() {
  local IOJS_VERSION
  IOJS_VERSION="$1"
  local STRIPPED_IOJS_VERSION
  STRIPPED_IOJS_VERSION="$(nvm_strip_iojs_prefix "${IOJS_VERSION}")"
  if [ "_${STRIPPED_IOJS_VERSION}" = "${IOJS_VERSION}" ]; then
    return 1
  fi

  # io.js started shipping Solaris binaries with io.js v3.3.1
  nvm_version_greater_than_or_equal_to "${STRIPPED_IOJS_VERSION}" v3.3.1
}

# Succeeds if $NODE_VERSION represents a node version that has a
# Solaris binary, fails otherwise.
# Currently, node versions starting from v0.8.6 have a Solaris binary
# available.
nvm_node_version_has_solaris_binary() {
  local NODE_VERSION
  NODE_VERSION="$1"
  # Error out if $NODE_VERSION is actually an io.js version
  local STRIPPED_IOJS_VERSION
  STRIPPED_IOJS_VERSION="$(nvm_strip_iojs_prefix "${NODE_VERSION}")"
  if [ "_${STRIPPED_IOJS_VERSION}" != "_${NODE_VERSION}" ]; then
    return 1
  fi

  # node (unmerged) started shipping Solaris binaries with v0.8.6 and
  # node versions v1.0.0 or greater are not considered valid "unmerged" node
  # versions.
  nvm_version_greater_than_or_equal_to "${NODE_VERSION}" v0.8.6 \
  && ! nvm_version_greater_than_or_equal_to "${NODE_VERSION}" v1.0.0
}

# Succeeds if $VERSION represents a version (node, io.js or merged) that has a
# Solaris binary, fails otherwise.
nvm_has_solaris_binary() {
  local VERSION="${1-}"
  if nvm_is_merged_node_version "${VERSION}"; then
    return 0 # All merged node versions have a Solaris binary
  elif nvm_is_iojs_version "${VERSION}"; then
    nvm_iojs_version_has_solaris_binary "${VERSION}"
  else
    nvm_node_version_has_solaris_binary "${VERSION}"
  fi
}

nvm_sanitize_path() {
  local SANITIZED_PATH
  SANITIZED_PATH="${1-}"
  if [ "_${SANITIZED_PATH}" != "_${NVM_DIR}" ]; then
    SANITIZED_PATH="$(nvm_echo "${SANITIZED_PATH}" | command sed -e "s#${NVM_DIR}#\${NVM_DIR}#g")"
  fi
  if [ "_${SANITIZED_PATH}" != "_${HOME}" ]; then
    SANITIZED_PATH="$(nvm_echo "${SANITIZED_PATH}" | command sed -e "s#${HOME}#\${HOME}#g")"
  fi
  nvm_echo "${SANITIZED_PATH}"
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
    if [ -d "$FILE" ]; then
      if [ -n "${NVM_DEBUG-}" ]; then
        nvm_err "${FILE}"
      fi
      if ! nvm_check_file_permissions "${FILE}"; then
        return 2
      fi
    elif [ -e "$FILE" ] && [ ! -w "$FILE" ] && [ ! -O "$FILE" ]; then
      nvm_err "file is not writable or self-owned: $(nvm_sanitize_path "$FILE")"
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

  local DEFAULT_IFS
  DEFAULT_IFS=" $(nvm_echo t | command tr t \\t)
"
  if [ "${-#*e}" != "$-" ]; then
    set +e
    local EXIT_CODE
    IFS="${DEFAULT_IFS}" nvm "$@"
    EXIT_CODE="$?"
    set -e
    return "$EXIT_CODE"
  elif [ "${-#*a}" != "$-" ]; then
    set +a
    local EXIT_CODE
    IFS="${DEFAULT_IFS}" nvm "$@"
    EXIT_CODE="$?"
    set -a
    return "$EXIT_CODE"
  elif [ "${IFS}" != "${DEFAULT_IFS}" ]; then
    IFS="${DEFAULT_IFS}" nvm "$@"
    return "$?"
  fi

  local i
  for i in "$@"
  do
    case $i in
      --) break ;;
      '-h'|'help'|'--help')
        NVM_NO_COLORS=""
        for j in "$@"; do
          if [ "${j}" = '--no-colors' ]; then
            NVM_NO_COLORS="${j}"
            break
          fi
        done

        local INITIAL_COLOR_INFO
        local RED_INFO
        local GREEN_INFO
        local BLUE_INFO
        local CYAN_INFO
        local MAGENTA_INFO
        local YELLOW_INFO
        local BLACK_INFO
        local GREY_WHITE_INFO

        if [ -z "${NVM_NO_COLORS-}"  ] && nvm_has_colors; then
          INITIAL_COLOR_INFO='\033[0;32m g\033[0m \033[0;34m b\033[0m \033[0;33m y\033[0m \033[0;31m r\033[0m \033[0;37m e\033[0m'
          RED_INFO='\033[0;31m r\033[0m/\033[1;31mR\033[0m = \033[0;31mred\033[0m / \033[1;31mbold red\033[0m'
          GREEN_INFO='\033[0;32m g\033[0m/\033[1;32mG\033[0m = \033[0;32mgreen\033[0m / \033[1;32mbold green\033[0m'
          BLUE_INFO='\033[0;34m b\033[0m/\033[1;34mB\033[0m = \033[0;34mblue\033[0m / \033[1;34mbold blue\033[0m'
          CYAN_INFO='\033[0;36m c\033[0m/\033[1;36mC\033[0m = \033[0;36mcyan\033[0m / \033[1;36mbold cyan\033[0m'
          MAGENTA_INFO='\033[0;35m m\033[0m/\033[1;35mM\033[0m = \033[0;35mmagenta\033[0m / \033[1;35mbold magenta\033[0m'
          YELLOW_INFO='\033[0;33m y\033[0m/\033[1;33mY\033[0m = \033[0;33myellow\033[0m / \033[1;33mbold yellow\033[0m'
          BLACK_INFO='\033[0;30m k\033[0m/\033[1;30mK\033[0m = \033[0;30mblack\033[0m / \033[1;30mbold black\033[0m'
          GREY_WHITE_INFO='\033[0;37m e\033[0m/\033[1;37mW\033[0m = \033[0;37mlight grey\033[0m / \033[1;37mwhite\033[0m'
        else
          INITIAL_COLOR_INFO='gbYre'
          RED_INFO='r/R = red / bold red'
          GREEN_INFO='g/G = green / bold green'
          BLUE_INFO='b/B = blue / bold blue'
          CYAN_INFO='c/C = cyan / bold cyan'
          MAGENTA_INFO='m/M = magenta / bold magenta'
          YELLOW_INFO='y/Y = yellow / bold yellow'
          BLACK_INFO='k/K = black / bold black'
          GREY_WHITE_INFO='e/W = light grey / white'
        fi

        local NVM_IOJS_PREFIX
        NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
        local NVM_NODE_PREFIX
        NVM_NODE_PREFIX="$(nvm_node_prefix)"
        NVM_VERSION="$(nvm --version)"
        nvm_echo
        nvm_echo "Node Version Manager (v${NVM_VERSION})"
        nvm_echo
        nvm_echo 'Note: <version> refers to any version-like string nvm understands. This includes:'
        nvm_echo '  - full or partial version numbers, starting with an optional "v" (0.10, v0.1.2, v1)'
        nvm_echo "  - default (built-in) aliases: ${NVM_NODE_PREFIX}, stable, unstable, ${NVM_IOJS_PREFIX}, system"
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
        nvm_echo_with_colors "                                                  ${INITIAL_COLOR_INFO}"
        nvm_echo '                                               Color codes:'
        nvm_echo_with_colors "                                                ${RED_INFO}"
        nvm_echo_with_colors "                                                ${GREEN_INFO}"
        nvm_echo_with_colors "                                                ${BLUE_INFO}"
        nvm_echo_with_colors "                                                ${CYAN_INFO}"
        nvm_echo_with_colors "                                                ${MAGENTA_INFO}"
        nvm_echo_with_colors "                                                ${YELLOW_INFO}"
        nvm_echo_with_colors "                                                ${BLACK_INFO}"
        nvm_echo_with_colors "                                                ${GREY_WHITE_INFO}"
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
        nvm_echo '  to remove, delete, or uninstall nvm - just remove the `$NVM_DIR` folder (usually `~/.nvm`)'
        nvm_echo
        return 0;
      ;;
    esac
  done

  local COMMAND
  COMMAND="${1-}"
  shift

  # initialize local variables
  local VERSION
  local ADDITIONAL_PARAMETERS

  case $COMMAND in
    "cache")
      case "${1-}" in
        dir) nvm_cache_dir ;;
        clear)
          local DIR
          DIR="$(nvm_cache_dir)"
          if command rm -rf "${DIR}" && command mkdir -p "${DIR}"; then
            nvm_echo 'nvm cache cleared.'
          else
            nvm_err "Unable to clear nvm cache: ${DIR}"
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
      local OS_VERSION
      nvm_is_zsh && setopt local_options shwordsplit
      nvm_err "nvm --version: v$(nvm --version)"
      if [ -n "${TERM_PROGRAM-}" ]; then
        nvm_err "\$TERM_PROGRAM: ${TERM_PROGRAM}"
      fi
      nvm_err "\$SHELL: ${SHELL}"
      # shellcheck disable=SC2169,SC3028
      nvm_err "\$SHLVL: ${SHLVL-}"
      nvm_err "whoami: '$(whoami)'"
      nvm_err "\${HOME}: ${HOME}"
      nvm_err "\${NVM_DIR}: '$(nvm_sanitize_path "${NVM_DIR}")'"
      nvm_err "\${PATH}: $(nvm_sanitize_path "${PATH}")"
      nvm_err "\$PREFIX: '$(nvm_sanitize_path "${PREFIX}")'"
      nvm_err "\${NPM_CONFIG_PREFIX}: '$(nvm_sanitize_path "${NPM_CONFIG_PREFIX}")'"
      nvm_err "\$NVM_NODEJS_ORG_MIRROR: '${NVM_NODEJS_ORG_MIRROR}'"
      nvm_err "\$NVM_IOJS_ORG_MIRROR: '${NVM_IOJS_ORG_MIRROR}'"
      nvm_err "shell version: '$(${SHELL} --version | command head -n 1)'"
      nvm_err "uname -a: '$(command uname -a | command awk '{$2=""; print}' | command xargs)'"
      nvm_err "checksum binary: '$(nvm_get_checksum_binary 2>/dev/null)'"
      if [ "$(nvm_get_os)" = "darwin" ] && nvm_has sw_vers; then
        OS_VERSION="$(sw_vers | command awk '{print $2}' | command xargs)"
      elif [ -r "/etc/issue" ]; then
        OS_VERSION="$(command head -n 1 /etc/issue | command sed 's/\\.//g')"
        if [ -z "${OS_VERSION}" ] && [ -r "/etc/os-release" ]; then
          # shellcheck disable=SC1091
          OS_VERSION="$(. /etc/os-release && echo "${NAME}" "${VERSION}")"
        fi
      fi
      if [ -n "${OS_VERSION}" ]; then
        nvm_err "OS version: ${OS_VERSION}"
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

      local TEST_TOOLS ADD_TEST_TOOLS
      TEST_TOOLS="git grep awk"
      ADD_TEST_TOOLS="sed cut basename rm mkdir xargs"
      if [ "darwin" != "$(nvm_get_os)" ] && [ "freebsd" != "$(nvm_get_os)" ]; then
        TEST_TOOLS="${TEST_TOOLS} ${ADD_TEST_TOOLS}"
      else
        for tool in ${ADD_TEST_TOOLS} ; do
          if nvm_has "${tool}"; then
            nvm_err "${tool}: $(nvm_command_info "${tool}")"
          else
            nvm_err "${tool}: not found"
          fi
        done
      fi
      for tool in ${TEST_TOOLS} ; do
        local NVM_TOOL_VERSION
        if nvm_has "${tool}"; then
          if command ls -l "$(nvm_command_info "${tool}" | command awk '{print $1}')" | command grep -q busybox; then
            NVM_TOOL_VERSION="$(command "${tool}" --help 2>&1 | command head -n 1)"
          else
            NVM_TOOL_VERSION="$(command "${tool}" --version 2>&1 | command head -n 1)"
          fi
          nvm_err "${tool}: $(nvm_command_info "${tool}"), ${NVM_TOOL_VERSION}"
        else
          nvm_err "${tool}: not found"
        fi
        unset NVM_TOOL_VERSION
      done
      unset TEST_TOOLS ADD_TEST_TOOLS

      local NVM_DEBUG_OUTPUT
      for NVM_DEBUG_COMMAND in 'nvm current' 'which node' 'which iojs' 'which npm' 'npm config get prefix' 'npm root -g'; do
        NVM_DEBUG_OUTPUT="$(${NVM_DEBUG_COMMAND} 2>&1)"
        nvm_err "${NVM_DEBUG_COMMAND}: $(nvm_sanitize_path "${NVM_DEBUG_OUTPUT}")"
      done
      return 42
    ;;

    "install" | "i")
      local version_not_provided
      version_not_provided=0
      local NVM_OS
      NVM_OS="$(nvm_get_os)"

      if ! nvm_has "curl" && ! nvm_has "wget"; then
        nvm_err 'nvm needs curl or wget to proceed.'
        return 1
      fi

      if [ $# -lt 1 ]; then
        version_not_provided=1
      fi

      local nobinary
      local nosource
      local noprogress
      nobinary=0
      noprogress=0
      nosource=0
      local LTS
      local ALIAS
      local NVM_UPGRADE_NPM
      NVM_UPGRADE_NPM=0

      local PROVIDED_REINSTALL_PACKAGES_FROM
      local REINSTALL_PACKAGES_FROM
      local SKIP_DEFAULT_PACKAGES
      local DEFAULT_PACKAGES

      while [ $# -ne 0 ]; do
        case "$1" in
          ---*)
            nvm_err 'arguments with `---` are not supported - this is likely a typo'
            return 55;
          ;;
          -s)
            shift # consume "-s"
            nobinary=1
            if [ $nosource -eq 1 ]; then
                nvm err '-s and -b cannot be set together since they would skip install from both binary and source'
                return 6
            fi
          ;;
          -b)
            shift # consume "-b"
            nosource=1
            if [ $nobinary -eq 1 ]; then
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
            noprogress=1
            shift
          ;;
          --lts)
            LTS='*'
            shift
          ;;
          --lts=*)
            LTS="${1##--lts=}"
            shift
          ;;
          --latest-npm)
            NVM_UPGRADE_NPM=1
            shift
          ;;
          --default)
            if [ -n "${ALIAS-}" ]; then
              nvm_err '--default and --alias are mutually exclusive, and may not be provided more than once'
              return 6
            fi
            ALIAS='default'
            shift
          ;;
          --alias=*)
            if [ -n "${ALIAS-}" ]; then
              nvm_err '--default and --alias are mutually exclusive, and may not be provided more than once'
              return 6
            fi
            ALIAS="${1##--alias=}"
            shift
          ;;
          --reinstall-packages-from=*)
            if [ -n "${PROVIDED_REINSTALL_PACKAGES_FROM-}" ]; then
              nvm_err '--reinstall-packages-from may not be provided more than once'
              return 6
            fi
            PROVIDED_REINSTALL_PACKAGES_FROM="$(nvm_echo "$1" | command cut -c 27-)"
            if [ -z "${PROVIDED_REINSTALL_PACKAGES_FROM}" ]; then
              nvm_err 'If --reinstall-packages-from is provided, it must point to an installed version of node.'
              return 6
            fi
            REINSTALL_PACKAGES_FROM="$(nvm_version "${PROVIDED_REINSTALL_PACKAGES_FROM}")" ||:
            shift
          ;;
          --copy-packages-from=*)
            if [ -n "${PROVIDED_REINSTALL_PACKAGES_FROM-}" ]; then
              nvm_err '--reinstall-packages-from may not be provided more than once, or combined with `--copy-packages-from`'
              return 6
            fi
            PROVIDED_REINSTALL_PACKAGES_FROM="$(nvm_echo "$1" | command cut -c 22-)"
            if [ -z "${PROVIDED_REINSTALL_PACKAGES_FROM}" ]; then
              nvm_err 'If --copy-packages-from is provided, it must point to an installed version of node.'
              return 6
            fi
            REINSTALL_PACKAGES_FROM="$(nvm_version "${PROVIDED_REINSTALL_PACKAGES_FROM}")" ||:
            shift
          ;;
          --reinstall-packages-from | --copy-packages-from)
            nvm_err "If ${1} is provided, it must point to an installed version of node using \`=\`."
            return 6
          ;;
          --skip-default-packages)
            SKIP_DEFAULT_PACKAGES=true
            shift
          ;;
          *)
            break # stop parsing args
          ;;
        esac
      done

      local provided_version
      provided_version="${1-}"

      if [ -z "${provided_version}" ]; then
        if [ "_${LTS-}" = '_*' ]; then
          nvm_echo 'Installing latest LTS version.'
          if [ $# -gt 0 ]; then
            shift
          fi
        elif [ "_${LTS-}" != '_' ]; then
          nvm_echo "Installing with latest version of LTS line: ${LTS}"
          if [ $# -gt 0 ]; then
            shift
          fi
        else
          nvm_rc_version
          if [ $version_not_provided -eq 1 ] && [ -z "${NVM_RC_VERSION}" ]; then
            unset NVM_RC_VERSION
            >&2 nvm --help
            return 127
          fi
          provided_version="${NVM_RC_VERSION}"
          unset NVM_RC_VERSION
        fi
      elif [ $# -gt 0 ]; then
        shift
      fi

      case "${provided_version}" in
        'lts/*')
          LTS='*'
          provided_version=''
        ;;
        lts/*)
          LTS="${provided_version##lts/}"
          provided_version=''
        ;;
      esac

      VERSION="$(NVM_VERSION_ONLY=true NVM_LTS="${LTS-}" nvm_remote_version "${provided_version}")"

      if [ "${VERSION}" = 'N/A' ]; then
        local LTS_MSG
        local REMOTE_CMD
        if [ "${LTS-}" = '*' ]; then
          LTS_MSG='(with LTS filter) '
          REMOTE_CMD='nvm ls-remote --lts'
        elif [ -n "${LTS-}" ]; then
          LTS_MSG="(with LTS filter '${LTS}') "
          REMOTE_CMD="nvm ls-remote --lts=${LTS}"
        else
          REMOTE_CMD='nvm ls-remote'
        fi
        nvm_err "Version '${provided_version}' ${LTS_MSG-}not found - try \`${REMOTE_CMD}\` to browse available versions."
        return 3
      fi

      ADDITIONAL_PARAMETERS=''

      while [ $# -ne 0 ]; do
        case "$1" in
          --reinstall-packages-from=*)
            if [ -n "${PROVIDED_REINSTALL_PACKAGES_FROM-}" ]; then
              nvm_err '--reinstall-packages-from may not be provided more than once'
              return 6
            fi
            PROVIDED_REINSTALL_PACKAGES_FROM="$(nvm_echo "$1" | command cut -c 27-)"
            if [ -z "${PROVIDED_REINSTALL_PACKAGES_FROM}" ]; then
              nvm_err 'If --reinstall-packages-from is provided, it must point to an installed version of node.'
              return 6
            fi
            REINSTALL_PACKAGES_FROM="$(nvm_version "${PROVIDED_REINSTALL_PACKAGES_FROM}")" ||:
          ;;
          --copy-packages-from=*)
            if [ -n "${PROVIDED_REINSTALL_PACKAGES_FROM-}" ]; then
              nvm_err '--reinstall-packages-from may not be provided more than once, or combined with `--copy-packages-from`'
              return 6
            fi
            PROVIDED_REINSTALL_PACKAGES_FROM="$(nvm_echo "$1" | command cut -c 22-)"
            if [ -z "${PROVIDED_REINSTALL_PACKAGES_FROM}" ]; then
              nvm_err 'If --copy-packages-from is provided, it must point to an installed version of node.'
              return 6
            fi
            REINSTALL_PACKAGES_FROM="$(nvm_version "${PROVIDED_REINSTALL_PACKAGES_FROM}")" ||:
          ;;
          --reinstall-packages-from | --copy-packages-from)
            nvm_err "If ${1} is provided, it must point to an installed version of node using \`=\`."
            return 6
          ;;
          --skip-default-packages)
            SKIP_DEFAULT_PACKAGES=true
          ;;
          *)
            ADDITIONAL_PARAMETERS="${ADDITIONAL_PARAMETERS} $1"
          ;;
        esac
        shift
      done

      if [ -z "${SKIP_DEFAULT_PACKAGES-}" ]; then
        DEFAULT_PACKAGES="$(nvm_get_default_packages)"
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ]; then
          return $EXIT_CODE
        fi
      fi

      if [ -n "${PROVIDED_REINSTALL_PACKAGES_FROM-}" ] && [ "$(nvm_ensure_version_prefix "${PROVIDED_REINSTALL_PACKAGES_FROM}")" = "${VERSION}" ]; then
        nvm_err "You can't reinstall global packages from the same version of node you're installing."
        return 4
      elif [ "${REINSTALL_PACKAGES_FROM-}" = 'N/A' ]; then
        nvm_err "If --reinstall-packages-from is provided, it must point to an installed version of node."
        return 5
      fi

      local FLAVOR
      if nvm_is_iojs_version "${VERSION}"; then
        FLAVOR="$(nvm_iojs_prefix)"
      else
        FLAVOR="$(nvm_node_prefix)"
      fi

      if nvm_is_version_installed "${VERSION}"; then
        nvm_err "${VERSION} is already installed."
        if nvm use "${VERSION}"; then
          if [ "${NVM_UPGRADE_NPM}" = 1 ]; then
            nvm install-latest-npm
          fi
          if [ -z "${SKIP_DEFAULT_PACKAGES-}" ] && [ -n "${DEFAULT_PACKAGES-}" ]; then
            nvm_install_default_packages "${DEFAULT_PACKAGES}"
          fi
          if [ -n "${REINSTALL_PACKAGES_FROM-}" ] && [ "_${REINSTALL_PACKAGES_FROM}" != "_N/A" ]; then
            nvm reinstall-packages "${REINSTALL_PACKAGES_FROM}"
          fi
        fi
        if [ -n "${LTS-}" ]; then
          LTS="$(echo "${LTS}" | tr '[:upper:]' '[:lower:]')"
          nvm_ensure_default_set "lts/${LTS}"
        else
          nvm_ensure_default_set "${provided_version}"
        fi

        if [ -n "${ALIAS-}" ]; then
          nvm alias "${ALIAS}" "${provided_version}"
        fi

        return $?
      fi

      local EXIT_CODE
      EXIT_CODE=-1
      if [ -n "${NVM_INSTALL_THIRD_PARTY_HOOK-}" ]; then
        nvm_err '** $NVM_INSTALL_THIRD_PARTY_HOOK env var set; dispatching to third-party installation method **'
        local NVM_METHOD_PREFERENCE
        NVM_METHOD_PREFERENCE='binary'
        if [ $nobinary -eq 1 ]; then
          NVM_METHOD_PREFERENCE='source'
        fi
        local VERSION_PATH
        VERSION_PATH="$(nvm_version_path "${VERSION}")"
        "${NVM_INSTALL_THIRD_PARTY_HOOK}" "${VERSION}" "${FLAVOR}" std "${NVM_METHOD_PREFERENCE}" "${VERSION_PATH}" || {
          EXIT_CODE=$?
          nvm_err '*** Third-party $NVM_INSTALL_THIRD_PARTY_HOOK env var failed to install! ***'
          return $EXIT_CODE
        }
        if ! nvm_is_version_installed "${VERSION}"; then
          nvm_err '*** Third-party $NVM_INSTALL_THIRD_PARTY_HOOK env var claimed to succeed, but failed to install! ***'
          return 33
        fi
        EXIT_CODE=0
      else

        if [ "_${NVM_OS}" = "_freebsd" ]; then
          # node.js and io.js do not have a FreeBSD binary
          nobinary=1
          nvm_err "Currently, there is no binary for FreeBSD"
        elif [ "_$NVM_OS" = "_openbsd" ]; then
          # node.js and io.js do not have a OpenBSD binary
          nobinary=1
          nvm_err "Currently, there is no binary for OpenBSD"
        elif [ "_${NVM_OS}" = "_sunos" ]; then
          # Not all node/io.js versions have a Solaris binary
          if ! nvm_has_solaris_binary "${VERSION}"; then
            nobinary=1
            nvm_err "Currently, there is no binary of version ${VERSION} for SunOS"
          fi
        fi

        # skip binary install if "nobinary" option specified.
        if [ $nobinary -ne 1 ] && nvm_binary_available "${VERSION}"; then
          NVM_NO_PROGRESS="${NVM_NO_PROGRESS:-${noprogress}}" nvm_install_binary "${FLAVOR}" std "${VERSION}" "${nosource}"
          EXIT_CODE=$?
        fi
        if [ $EXIT_CODE -ne 0 ]; then
          if [ -z "${NVM_MAKE_JOBS-}" ]; then
            nvm_get_make_jobs
          fi

          if [ "_${NVM_OS}" = "_win" ]; then
            nvm_err 'Installing from source on non-WSL Windows is not supported'
            EXIT_CODE=87
          else
            NVM_NO_PROGRESS="${NVM_NO_PROGRESS:-${noprogress}}" nvm_install_source "${FLAVOR}" std "${VERSION}" "${NVM_MAKE_JOBS}" "${ADDITIONAL_PARAMETERS}"
            EXIT_CODE=$?
          fi
        fi

      fi

      if [ $EXIT_CODE -eq 0 ] && nvm_use_if_needed "${VERSION}" && nvm_install_npm_if_needed "${VERSION}"; then
        if [ -n "${LTS-}" ]; then
          nvm_ensure_default_set "lts/${LTS}"
        else
          nvm_ensure_default_set "${provided_version}"
        fi
        if [ "${NVM_UPGRADE_NPM}" = 1 ]; then
          nvm install-latest-npm
          EXIT_CODE=$?
        fi
        if [ -z "${SKIP_DEFAULT_PACKAGES-}" ] && [ -n "${DEFAULT_PACKAGES-}" ]; then
          nvm_install_default_packages "${DEFAULT_PACKAGES}"
        fi
        if [ -n "${REINSTALL_PACKAGES_FROM-}" ] && [ "_${REINSTALL_PACKAGES_FROM}" != "_N/A" ]; then
          nvm reinstall-packages "${REINSTALL_PACKAGES_FROM}"
          EXIT_CODE=$?
        fi
      else
        EXIT_CODE=$?
      fi
      return $EXIT_CODE
    ;;
    "uninstall")
      if [ $# -ne 1 ]; then
        >&2 nvm --help
        return 127
      fi

      local PATTERN
      PATTERN="${1-}"
      case "${PATTERN-}" in
        --) ;;
        --lts | 'lts/*')
          VERSION="$(nvm_match_version "lts/*")"
        ;;
        lts/*)
          VERSION="$(nvm_match_version "lts/${PATTERN##lts/}")"
        ;;
        --lts=*)
          VERSION="$(nvm_match_version "lts/${PATTERN##--lts=}")"
        ;;
        *)
          VERSION="$(nvm_version "${PATTERN}")"
        ;;
      esac

      if [ "_${VERSION}" = "_$(nvm_ls_current)" ]; then
        if nvm_is_iojs_version "${VERSION}"; then
          nvm_err "nvm: Cannot uninstall currently-active io.js version, ${VERSION} (inferred from ${PATTERN})."
        else
          nvm_err "nvm: Cannot uninstall currently-active node version, ${VERSION} (inferred from ${PATTERN})."
        fi
        return 1
      fi

      if ! nvm_is_version_installed "${VERSION}"; then
        nvm_err "${VERSION} version is not installed..."
        return
      fi

      local SLUG_BINARY
      local SLUG_SOURCE
      if nvm_is_iojs_version "${VERSION}"; then
        SLUG_BINARY="$(nvm_get_download_slug iojs binary std "${VERSION}")"
        SLUG_SOURCE="$(nvm_get_download_slug iojs source std "${VERSION}")"
      else
        SLUG_BINARY="$(nvm_get_download_slug node binary std "${VERSION}")"
        SLUG_SOURCE="$(nvm_get_download_slug node source std "${VERSION}")"
      fi

      local NVM_SUCCESS_MSG
      if nvm_is_iojs_version "${VERSION}"; then
        NVM_SUCCESS_MSG="Uninstalled io.js $(nvm_strip_iojs_prefix "${VERSION}")"
      else
        NVM_SUCCESS_MSG="Uninstalled node ${VERSION}"
      fi

      local VERSION_PATH
      VERSION_PATH="$(nvm_version_path "${VERSION}")"
      if ! nvm_check_file_permissions "${VERSION_PATH}"; then
        nvm_err 'Cannot uninstall, incorrect permissions on installation folder.'
        nvm_err 'This is usually caused by running `npm install -g` as root. Run the following commands as root to fix the permissions and then try again.'
        nvm_err
        nvm_err "  chown -R $(whoami) \"$(nvm_sanitize_path "${VERSION_PATH}")\""
        nvm_err "  chmod -R u+w \"$(nvm_sanitize_path "${VERSION_PATH}")\""
        return 1
      fi

      # Delete all files related to target version.
      local CACHE_DIR
      CACHE_DIR="$(nvm_cache_dir)"
      command rm -rf \
        "${CACHE_DIR}/bin/${SLUG_BINARY}/files" \
        "${CACHE_DIR}/src/${SLUG_SOURCE}/files" \
        "${VERSION_PATH}" 2>/dev/null
      nvm_echo "${NVM_SUCCESS_MSG}"

      # rm any aliases that point to uninstalled version.
      for ALIAS in $(nvm_grep -l "${VERSION}" "$(nvm_alias_path)/*" 2>/dev/null); do
        nvm unalias "$(command basename "${ALIAS}")"
      done
    ;;
    "deactivate")
      local NVM_SILENT
      while [ $# -ne 0 ]; do
        case "${1}" in
          --silent) NVM_SILENT=1 ;;
          --) ;;
        esac
        shift
      done
      local NEWPATH
      NEWPATH="$(nvm_strip_path "${PATH}" "/bin")"
      if [ "_${PATH}" = "_${NEWPATH}" ]; then
        if [ "${NVM_SILENT:-0}" -ne 1 ]; then
          nvm_err "Could not find ${NVM_DIR}/*/bin in \${PATH}"
        fi
      else
        export PATH="${NEWPATH}"
        hash -r
        if [ "${NVM_SILENT:-0}" -ne 1 ]; then
          nvm_echo "${NVM_DIR}/*/bin removed from \${PATH}"
        fi
      fi

      if [ -n "${MANPATH-}" ]; then
        NEWPATH="$(nvm_strip_path "${MANPATH}" "/share/man")"
        if [ "_${MANPATH}" = "_${NEWPATH}" ]; then
          if [ "${NVM_SILENT:-0}" -ne 1 ]; then
            nvm_err "Could not find ${NVM_DIR}/*/share/man in \${MANPATH}"
          fi
        else
          export MANPATH="${NEWPATH}"
          if [ "${NVM_SILENT:-0}" -ne 1 ]; then
            nvm_echo "${NVM_DIR}/*/share/man removed from \${MANPATH}"
          fi
        fi
      fi

      if [ -n "${NODE_PATH-}" ]; then
        NEWPATH="$(nvm_strip_path "${NODE_PATH}" "/lib/node_modules")"
        if [ "_${NODE_PATH}" != "_${NEWPATH}" ]; then
          export NODE_PATH="${NEWPATH}"
          if [ "${NVM_SILENT:-0}" -ne 1 ]; then
            nvm_echo "${NVM_DIR}/*/lib/node_modules removed from \${NODE_PATH}"
          fi
        fi
      fi
      unset NVM_BIN
      unset NVM_INC
    ;;
    "use")
      local PROVIDED_VERSION
      local NVM_SILENT
      local NVM_SILENT_ARG
      local NVM_DELETE_PREFIX
      NVM_DELETE_PREFIX=0
      local NVM_LTS

      while [ $# -ne 0 ]; do
        case "$1" in
          --silent)
            NVM_SILENT=1
            NVM_SILENT_ARG='--silent'
          ;;
          --delete-prefix) NVM_DELETE_PREFIX=1 ;;
          --) ;;
          --lts) NVM_LTS='*' ;;
          --lts=*) NVM_LTS="${1##--lts=}" ;;
          --*) ;;
          *)
            if [ -n "${1-}" ]; then
              PROVIDED_VERSION="$1"
            fi
          ;;
        esac
        shift
      done

      if [ -n "${NVM_LTS-}" ]; then
        VERSION="$(nvm_match_version "lts/${NVM_LTS:-*}")"
      elif [ -z "${PROVIDED_VERSION-}" ]; then
        NVM_SILENT="${NVM_SILENT:-0}" nvm_rc_version
        if [ -n "${NVM_RC_VERSION-}" ]; then
          PROVIDED_VERSION="${NVM_RC_VERSION}"
          VERSION="$(nvm_version "${PROVIDED_VERSION}")"
        fi
        unset NVM_RC_VERSION
        if [ -z "${VERSION}" ]; then
          nvm_err 'Please see `nvm --help` or https://github.com/nvm-sh/nvm#nvmrc for more information.'
          return 127
        fi
      else
        VERSION="$(nvm_match_version "${PROVIDED_VERSION}")"
      fi

      if [ -z "${VERSION}" ]; then
        >&2 nvm --help
        return 127
      fi

      if [ "_${VERSION}" = '_system' ]; then
        if nvm_has_system_node && nvm deactivate "${NVM_SILENT_ARG-}" >/dev/null 2>&1; then
          if [ "${NVM_SILENT:-0}" -ne 1 ]; then
            nvm_echo "Now using system version of node: $(node -v 2>/dev/null)$(nvm_print_npm_version)"
          fi
          return
        elif nvm_has_system_iojs && nvm deactivate "${NVM_SILENT_ARG-}" >/dev/null 2>&1; then
          if [ "${NVM_SILENT:-0}" -ne 1 ]; then
            nvm_echo "Now using system version of io.js: $(iojs --version 2>/dev/null)$(nvm_print_npm_version)"
          fi
          return
        elif [ "${NVM_SILENT:-0}" -ne 1 ]; then
          nvm_err 'System version of node not found.'
        fi
        return 127
      elif [ "_${VERSION}" = "_∞" ]; then
        if [ "${NVM_SILENT:-0}" -ne 1 ]; then
          nvm_err "The alias \"${PROVIDED_VERSION}\" leads to an infinite loop. Aborting."
        fi
        return 8
      fi
      if [ "${VERSION}" = 'N/A' ]; then
        if [ "${NVM_SILENT:-0}" -ne 1 ]; then
          nvm_err "N/A: version \"${PROVIDED_VERSION} -> ${VERSION}\" is not yet installed."
          nvm_err ""
          nvm_err "You need to run \"nvm install ${PROVIDED_VERSION}\" to install it before using it."
        fi
        return 3
      # This nvm_ensure_version_installed call can be a performance bottleneck
      # on shell startup. Perhaps we can optimize it away or make it faster.
      elif ! nvm_ensure_version_installed "${VERSION}"; then
        return $?
      fi

      local NVM_VERSION_DIR
      NVM_VERSION_DIR="$(nvm_version_path "${VERSION}")"

      # Change current version
      PATH="$(nvm_change_path "${PATH}" "/bin" "${NVM_VERSION_DIR}")"
      if nvm_has manpath; then
        if [ -z "${MANPATH-}" ]; then
          local MANPATH
          MANPATH=$(manpath)
        fi
        # Change current version
        MANPATH="$(nvm_change_path "${MANPATH}" "/share/man" "${NVM_VERSION_DIR}")"
        export MANPATH
      fi
      export PATH
      hash -r
      export NVM_BIN="${NVM_VERSION_DIR}/bin"
      export NVM_INC="${NVM_VERSION_DIR}/include/node"
      if [ "${NVM_SYMLINK_CURRENT-}" = true ]; then
        command rm -f "${NVM_DIR}/current" && ln -s "${NVM_VERSION_DIR}" "${NVM_DIR}/current"
      fi
      local NVM_USE_OUTPUT
      NVM_USE_OUTPUT=''
      if [ "${NVM_SILENT:-0}" -ne 1 ]; then
        if nvm_is_iojs_version "${VERSION}"; then
          NVM_USE_OUTPUT="Now using io.js $(nvm_strip_iojs_prefix "${VERSION}")$(nvm_print_npm_version)"
        else
          NVM_USE_OUTPUT="Now using node ${VERSION}$(nvm_print_npm_version)"
        fi
      fi
      if [ "_${VERSION}" != "_system" ]; then
        local NVM_USE_CMD
        NVM_USE_CMD="nvm use --delete-prefix"
        if [ -n "${PROVIDED_VERSION}" ]; then
          NVM_USE_CMD="${NVM_USE_CMD} ${VERSION}"
        fi
        if [ "${NVM_SILENT:-0}" -eq 1 ]; then
          NVM_USE_CMD="${NVM_USE_CMD} --silent"
        fi
        if ! nvm_die_on_prefix "${NVM_DELETE_PREFIX}" "${NVM_USE_CMD}" "${NVM_VERSION_DIR}"; then
          return 11
        fi
      fi
      if [ -n "${NVM_USE_OUTPUT-}" ] && [ "${NVM_SILENT:-0}" -ne 1 ]; then
        nvm_echo "${NVM_USE_OUTPUT}"
      fi
    ;;
    "run")
      local provided_version
      local has_checked_nvmrc
      has_checked_nvmrc=0
      # run given version of node

      local NVM_SILENT
      local NVM_SILENT_ARG
      local NVM_LTS
      while [ $# -gt 0 ]; do
        case "$1" in
          --silent)
            NVM_SILENT=1
            NVM_SILENT_ARG='--silent'
            shift
          ;;
          --lts) NVM_LTS='*' ; shift ;;
          --lts=*) NVM_LTS="${1##--lts=}" ; shift ;;
          *)
            if [ -n "$1" ]; then
              break
            else
              shift
            fi
          ;; # stop processing arguments
        esac
      done

      if [ $# -lt 1 ] && [ -z "${NVM_LTS-}" ]; then
        NVM_SILENT="${NVM_SILENT:-0}" nvm_rc_version && has_checked_nvmrc=1
        if [ -n "${NVM_RC_VERSION-}" ]; then
          VERSION="$(nvm_version "${NVM_RC_VERSION-}")" ||:
        fi
        unset NVM_RC_VERSION
        if [ "${VERSION:-N/A}" = 'N/A' ]; then
          >&2 nvm --help
          return 127
        fi
      fi

      if [ -z "${NVM_LTS-}" ]; then
        provided_version="$1"
        if [ -n "${provided_version}" ]; then
          VERSION="$(nvm_version "${provided_version}")" ||:
          if [ "_${VERSION:-N/A}" = '_N/A' ] && ! nvm_is_valid_version "${provided_version}"; then
            provided_version=''
            if [ $has_checked_nvmrc -ne 1 ]; then
              NVM_SILENT="${NVM_SILENT:-0}" nvm_rc_version && has_checked_nvmrc=1
            fi
            VERSION="$(nvm_version "${NVM_RC_VERSION}")" ||:
            unset NVM_RC_VERSION
          else
            shift
          fi
        fi
      fi

      local NVM_IOJS
      if nvm_is_iojs_version "${VERSION}"; then
        NVM_IOJS=true
      fi

      local EXIT_CODE

      nvm_is_zsh && setopt local_options shwordsplit
      local LTS_ARG
      if [ -n "${NVM_LTS-}" ]; then
        LTS_ARG="--lts=${NVM_LTS-}"
        VERSION=''
      fi
      if [ "_${VERSION}" = "_N/A" ]; then
        nvm_ensure_version_installed "${provided_version}"
      elif [ "${NVM_IOJS}" = true ]; then
        nvm exec "${NVM_SILENT_ARG-}" "${LTS_ARG-}" "${VERSION}" iojs "$@"
      else
        nvm exec "${NVM_SILENT_ARG-}" "${LTS_ARG-}" "${VERSION}" node "$@"
      fi
      EXIT_CODE="$?"
      return $EXIT_CODE
    ;;
    "exec")
      local NVM_SILENT
      local NVM_LTS
      while [ $# -gt 0 ]; do
        case "$1" in
          --silent) NVM_SILENT=1 ; shift ;;
          --lts) NVM_LTS='*' ; shift ;;
          --lts=*) NVM_LTS="${1##--lts=}" ; shift ;;
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

      local provided_version
      provided_version="$1"
      if [ "${NVM_LTS-}" != '' ]; then
        provided_version="lts/${NVM_LTS:-*}"
        VERSION="${provided_version}"
      elif [ -n "${provided_version}" ]; then
        VERSION="$(nvm_version "${provided_version}")" ||:
        if [ "_${VERSION}" = '_N/A' ] && ! nvm_is_valid_version "${provided_version}"; then
          NVM_SILENT="${NVM_SILENT:-0}" nvm_rc_version && has_checked_nvmrc=1
          provided_version="${NVM_RC_VERSION}"
          unset NVM_RC_VERSION
          VERSION="$(nvm_version "${provided_version}")" ||:
        else
          shift
        fi
      fi

      nvm_ensure_version_installed "${provided_version}"
      EXIT_CODE=$?
      if [ "${EXIT_CODE}" != "0" ]; then
        return $EXIT_CODE
      fi

      if [ "${NVM_SILENT:-0}" -ne 1 ]; then
        if [ "${NVM_LTS-}" = '*' ]; then
          nvm_echo "Running node latest LTS -> $(nvm_version "${VERSION}")$(nvm use --silent "${VERSION}" && nvm_print_npm_version)"
        elif [ -n "${NVM_LTS-}" ]; then
          nvm_echo "Running node LTS \"${NVM_LTS-}\" -> $(nvm_version "${VERSION}")$(nvm use --silent "${VERSION}" && nvm_print_npm_version)"
        elif nvm_is_iojs_version "${VERSION}"; then
          nvm_echo "Running io.js $(nvm_strip_iojs_prefix "${VERSION}")$(nvm use --silent "${VERSION}" && nvm_print_npm_version)"
        else
          nvm_echo "Running node ${VERSION}$(nvm use --silent "${VERSION}" && nvm_print_npm_version)"
        fi
      fi
      NODE_VERSION="${VERSION}" "${NVM_DIR}/nvm-exec" "$@"
    ;;
    "ls" | "list")
      local PATTERN
      local NVM_NO_COLORS
      local NVM_NO_ALIAS

      while [ $# -gt 0 ]; do
        case "${1}" in
          --) ;;
          --no-colors) NVM_NO_COLORS="${1}" ;;
          --no-alias) NVM_NO_ALIAS="${1}" ;;
          --*)
            nvm_err "Unsupported option \"${1}\"."
            return 55
          ;;
          *)
            PATTERN="${PATTERN:-$1}"
          ;;
        esac
        shift
      done
      if [ -n "${PATTERN-}" ] && [ -n "${NVM_NO_ALIAS-}" ]; then
        nvm_err '`--no-alias` is not supported when a pattern is provided.'
        return 55
      fi
      local NVM_LS_OUTPUT
      local NVM_LS_EXIT_CODE
      NVM_LS_OUTPUT=$(nvm_ls "${PATTERN-}")
      NVM_LS_EXIT_CODE=$?
      NVM_NO_COLORS="${NVM_NO_COLORS-}" nvm_print_versions "${NVM_LS_OUTPUT}"
      if [ -z "${NVM_NO_ALIAS-}" ] && [ -z "${PATTERN-}" ]; then
        if [ -n "${NVM_NO_COLORS-}" ]; then
          nvm alias --no-colors
        else
          nvm alias
        fi
      fi
      return $NVM_LS_EXIT_CODE
    ;;
    "ls-remote" | "list-remote")
      local NVM_LTS
      local PATTERN
      local NVM_NO_COLORS

      while [ $# -gt 0 ]; do
        case "${1-}" in
          --) ;;
          --lts)
            NVM_LTS='*'
          ;;
          --lts=*)
            NVM_LTS="${1##--lts=}"
          ;;
          --no-colors) NVM_NO_COLORS="${1}" ;;
          --*)
            nvm_err "Unsupported option \"${1}\"."
            return 55
          ;;
          *)
            if [ -z "${PATTERN-}" ]; then
              PATTERN="${1-}"
              if [ -z "${NVM_LTS-}" ]; then
                case "${PATTERN}" in
                  'lts/*')
                    NVM_LTS='*'
                    PATTERN=''
                  ;;
                  lts/*)
                    NVM_LTS="${PATTERN##lts/}"
                    PATTERN=''
                  ;;
                esac
              fi
            fi
          ;;
        esac
        shift
      done

      local NVM_OUTPUT
      local EXIT_CODE
      NVM_OUTPUT="$(NVM_LTS="${NVM_LTS-}" nvm_remote_versions "${PATTERN}" &&:)"
      EXIT_CODE=$?
      if [ -n "${NVM_OUTPUT}" ]; then
        NVM_NO_COLORS="${NVM_NO_COLORS-}" nvm_print_versions "${NVM_OUTPUT}"
        return $EXIT_CODE
      fi
      NVM_NO_COLORS="${NVM_NO_COLORS-}" nvm_print_versions "N/A"
      return 3
    ;;
    "current")
      nvm_version current
    ;;
    "which")
      local NVM_SILENT
      local provided_version
      while [ $# -ne 0 ]; do
        case "${1}" in
          --silent) NVM_SILENT=1 ;;
          --) ;;
          *) provided_version="${1-}" ;;
        esac
        shift
      done
      if [ -z "${provided_version-}" ]; then
        NVM_SILENT="${NVM_SILENT:-0}" nvm_rc_version
        if [ -n "${NVM_RC_VERSION}" ]; then
          provided_version="${NVM_RC_VERSION}"
          VERSION=$(nvm_version "${NVM_RC_VERSION}") ||:
        fi
        unset NVM_RC_VERSION
      elif [ "${provided_version}" != 'system' ]; then
        VERSION="$(nvm_version "${provided_version}")" ||:
      else
        VERSION="${provided_version-}"
      fi
      if [ -z "${VERSION}" ]; then
        >&2 nvm --help
        return 127
      fi

      if [ "_${VERSION}" = '_system' ]; then
        if nvm_has_system_iojs >/dev/null 2>&1 || nvm_has_system_node >/dev/null 2>&1; then
          local NVM_BIN
          NVM_BIN="$(nvm use system >/dev/null 2>&1 && command which node)"
          if [ -n "${NVM_BIN}" ]; then
            nvm_echo "${NVM_BIN}"
            return
          fi
          return 1
        fi
        nvm_err 'System version of node not found.'
        return 127
      elif [ "${VERSION}" = '∞' ]; then
        nvm_err "The alias \"${2}\" leads to an infinite loop. Aborting."
        return 8
      fi

      nvm_ensure_version_installed "${provided_version}"
      EXIT_CODE=$?
      if [ "${EXIT_CODE}" != "0" ]; then
        return $EXIT_CODE
      fi
      local NVM_VERSION_DIR
      NVM_VERSION_DIR="$(nvm_version_path "${VERSION}")"
      nvm_echo "${NVM_VERSION_DIR}/bin/node"
    ;;
    "alias")
      local NVM_ALIAS_DIR
      NVM_ALIAS_DIR="$(nvm_alias_path)"
      local NVM_CURRENT
      NVM_CURRENT="$(nvm_ls_current)"

      command mkdir -p "${NVM_ALIAS_DIR}/lts"

      local ALIAS
      local TARGET
      local NVM_NO_COLORS
      ALIAS='--'
      TARGET='--'

      while [ $# -gt 0 ]; do
        case "${1-}" in
          --) ;;
          --no-colors) NVM_NO_COLORS="${1}" ;;
          --*)
            nvm_err "Unsupported option \"${1}\"."
            return 55
          ;;
          *)
            if [ "${ALIAS}" = '--' ]; then
              ALIAS="${1-}"
            elif [ "${TARGET}" = '--' ]; then
              TARGET="${1-}"
            fi
          ;;
        esac
        shift
      done

      if [ -z "${TARGET}" ]; then
        # for some reason the empty string was explicitly passed as the target
        # so, unalias it.
        nvm unalias "${ALIAS}"
        return $?
      elif [ "${TARGET}" != '--' ]; then
        # a target was passed: create an alias
        if [ "${ALIAS#*\/}" != "${ALIAS}" ]; then
          nvm_err 'Aliases in subdirectories are not supported.'
          return 1
        fi
        VERSION="$(nvm_version "${TARGET}")" ||:
        if [ "${VERSION}" = 'N/A' ]; then
          nvm_err "! WARNING: Version '${TARGET}' does not exist."
        fi
        nvm_make_alias "${ALIAS}" "${TARGET}"
        NVM_NO_COLORS="${NVM_NO_COLORS-}" NVM_CURRENT="${NVM_CURRENT-}" DEFAULT=false nvm_print_formatted_alias "${ALIAS}" "${TARGET}" "${VERSION}"
      else
        if [ "${ALIAS-}" = '--' ]; then
          unset ALIAS
        fi

        nvm_list_aliases "${ALIAS-}"
      fi
    ;;
    "unalias")
      local NVM_ALIAS_DIR
      NVM_ALIAS_DIR="$(nvm_alias_path)"
      command mkdir -p "${NVM_ALIAS_DIR}"
      if [ $# -ne 1 ]; then
        >&2 nvm --help
        return 127
      fi
      if [ "${1#*\/}" != "${1-}" ]; then
        nvm_err 'Aliases in subdirectories are not supported.'
        return 1
      fi

      local NVM_IOJS_PREFIX
      local NVM_NODE_PREFIX
      NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
      NVM_NODE_PREFIX="$(nvm_node_prefix)"
      local NVM_ALIAS_EXISTS
      NVM_ALIAS_EXISTS=0
      if [ -f "${NVM_ALIAS_DIR}/${1-}" ]; then
        NVM_ALIAS_EXISTS=1
      fi

      if [ $NVM_ALIAS_EXISTS -eq 0 ]; then
        case "$1" in
          "stable" | "unstable" | "${NVM_IOJS_PREFIX}" | "${NVM_NODE_PREFIX}" | "system")
            nvm_err "${1-} is a default (built-in) alias and cannot be deleted."
            return 1
          ;;
        esac

        nvm_err "Alias ${1-} doesn't exist!"
        return
      fi

      local NVM_ALIAS_ORIGINAL
      NVM_ALIAS_ORIGINAL="$(nvm_alias "${1}")"
      command rm -f "${NVM_ALIAS_DIR}/${1}"
      nvm_echo "Deleted alias ${1} - restore it with \`nvm alias \"${1}\" \"${NVM_ALIAS_ORIGINAL}\"\`"
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

      local PROVIDED_VERSION
      PROVIDED_VERSION="${1-}"

      if [ "${PROVIDED_VERSION}" = "$(nvm_ls_current)" ] || [ "$(nvm_version "${PROVIDED_VERSION}" ||:)" = "$(nvm_ls_current)" ]; then
        nvm_err 'Can not reinstall packages from the current version of node.'
        return 2
      fi

      local VERSION
      if [ "_${PROVIDED_VERSION}" = "_system" ]; then
        if ! nvm_has_system_node && ! nvm_has_system_iojs; then
          nvm_err 'No system version of node or io.js detected.'
          return 3
        fi
        VERSION="system"
      else
        VERSION="$(nvm_version "${PROVIDED_VERSION}")" ||:
      fi

      local NPMLIST
      NPMLIST="$(nvm_npm_global_modules "${VERSION}")"
      local INSTALLS
      local LINKS
      INSTALLS="${NPMLIST%% //// *}"
      LINKS="${NPMLIST##* //// }"

      nvm_echo "Reinstalling global packages from ${VERSION}..."
      if [ -n "${INSTALLS}" ]; then
        nvm_echo "${INSTALLS}" | command xargs npm install -g --quiet
      else
        nvm_echo "No installed global packages found..."
      fi

      nvm_echo "Linking global packages from ${VERSION}..."
      if [ -n "${LINKS}" ]; then
        (
          set -f; IFS='
' # necessary to turn off variable expansion except for newlines
          for LINK in ${LINKS}; do
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
      local NVM_LTS
      local PATTERN
      while [ $# -gt 0 ]; do
        case "${1-}" in
          --) ;;
          --lts)
            NVM_LTS='*'
          ;;
          --lts=*)
            NVM_LTS="${1##--lts=}"
          ;;
          --*)
            nvm_err "Unsupported option \"${1}\"."
            return 55
          ;;
          *)
            PATTERN="${PATTERN:-${1}}"
          ;;
        esac
        shift
      done
      case "${PATTERN-}" in
        'lts/*')
          NVM_LTS='*'
          unset PATTERN
        ;;
        lts/*)
          NVM_LTS="${PATTERN##lts/}"
          unset PATTERN
        ;;
      esac
      NVM_VERSION_ONLY=true NVM_LTS="${NVM_LTS-}" nvm_remote_version "${PATTERN:-node}"
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
        nvm_get_artifact_compression nvm_install_binary_extract \
        >/dev/null 2>&1
      unset NVM_RC_VERSION NVM_NODEJS_ORG_MIRROR NVM_IOJS_ORG_MIRROR NVM_DIR \
        NVM_CD_FLAGS NVM_BIN NVM_INC NVM_MAKE_JOBS \
        NVM_COLORS INSTALLED_COLOR SYSTEM_COLOR \
        CURRENT_COLOR NOT_INSTALLED_COLOR DEFAULT_COLOR LTS_COLOR \
        >/dev/null 2>&1
    ;;
    "set-colors")
      local EXIT_CODE
      nvm_set_colors "${1-}"
      EXIT_CODE=$?
      if [ "$EXIT_CODE" -eq 17 ]; then
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
  local NVM_DEFAULT_PACKAGE_FILE="${NVM_DIR}/default-packages"
  if [ -f "${NVM_DEFAULT_PACKAGE_FILE}" ]; then
    local DEFAULT_PACKAGES
    DEFAULT_PACKAGES=''

    # Read lines from $NVM_DIR/default-packages
    local line
    # ensure a trailing newline
    WORK=$(mktemp -d) || exit $?
    # shellcheck disable=SC2064
    trap "command rm -rf '$WORK'" EXIT
    # shellcheck disable=SC1003
    sed -e '$a\' "${NVM_DEFAULT_PACKAGE_FILE}" > "${WORK}/default-packages"
    while IFS=' ' read -r line; do
      # Skip empty lines.
      [ -n "${line-}" ] || continue

      # Skip comment lines that begin with `#`.
      [ "$(nvm_echo "${line}" | command cut -c1)" != "#" ] || continue

      # Fail on lines that have multiple space-separated words
      case $line in
        *\ *)
          nvm_err "Only one package per line is allowed in the ${NVM_DIR}/default-packages file. Please remove any lines with multiple space-separated values."
          return 1
        ;;
      esac

      DEFAULT_PACKAGES="${DEFAULT_PACKAGES}${line} "
    done < "${WORK}/default-packages"
    echo "${DEFAULT_PACKAGES}" | command xargs
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

  local NVM_OS
  NVM_OS="$(nvm_get_os)"
  if [ "_${NVM_OS}" = '_darwin' ]; then
    local MACOS_VERSION
    MACOS_VERSION="$(sw_vers -productVersion)"
    if nvm_version_greater "10.9.0" "${MACOS_VERSION}"; then
      # macOS 10.8 and earlier doesn't support extracting xz-compressed tarballs with tar
      return 1
    fi
  elif [ "_${NVM_OS}" = '_freebsd' ]; then
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

  case "${NVM_OS}" in
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
  local NVM_MODE
  NVM_MODE="${1-}"
  local VERSION
  local NVM_CURRENT
  if [ "_${NVM_MODE}" = '_install' ]; then
    VERSION="$(nvm_alias default 2>/dev/null || nvm_echo)"
    if [ -n "${VERSION}" ]; then
      nvm install "${VERSION}" >/dev/null
    elif nvm_rc_version >/dev/null 2>&1; then
      nvm install >/dev/null
    fi
  elif [ "_$NVM_MODE" = '_use' ]; then
    NVM_CURRENT="$(nvm_ls_current)"
    if [ "_${NVM_CURRENT}" = '_none' ] || [ "_${NVM_CURRENT}" = '_system' ]; then
      VERSION="$(nvm_resolve_local_alias default 2>/dev/null || nvm_echo)"
      if [ -n "${VERSION}" ]; then
        nvm use --silent "${VERSION}" >/dev/null
      elif nvm_rc_version >/dev/null 2>&1; then
        nvm use --silent >/dev/null
      fi
    else
      nvm use --silent "${NVM_CURRENT}" >/dev/null
    fi
  elif [ "_${NVM_MODE}" != '_none' ]; then
    nvm_err 'Invalid auto mode supplied.'
    return 1
  fi
}

nvm_process_parameters() {
  local NVM_AUTO_MODE
  NVM_AUTO_MODE='use'
  while [ "$#" -ne 0 ]; do
    case "$1" in
      --install) NVM_AUTO_MODE='install' ;;
      --no-use) NVM_AUTO_MODE='none' ;;
    esac
    shift
  done
  nvm_auto "${NVM_AUTO_MODE}"
}

nvm_process_parameters "$@"

} # this ensures the entire script is downloaded #
