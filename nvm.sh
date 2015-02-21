# Node Version Manager
# Implemented as a POSIX-compliant function
# Should work on sh, dash, bash, ksh, zsh
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

NVM_SCRIPT_SOURCE="$_"

nvm_has() {
  type "$1" > /dev/null 2>&1
}

nvm_is_alias() {
  # this is intentionally not "command alias" so it works in zsh.
  \alias "$1" > /dev/null 2>&1
}

nvm_get_latest() {
  local NVM_LATEST_URL
  if nvm_has "curl"; then
    NVM_LATEST_URL="$(curl -w "%{url_effective}\n" -L -s -S http://latest.nvm.sh -o /dev/null)"
  elif nvm_has "wget"; then
    NVM_LATEST_URL="$(wget http://latest.nvm.sh --server-response -O /dev/null 2>&1 | awk '/^  Location: /{DEST=$2} END{ print DEST }')"
  else
    >&2 echo 'nvm needs curl or wget to proceed.'
    return 1
  fi
  if [ "_$NVM_LATEST_URL" = "_" ]; then
    >&2 echo "http://latest.nvm.sh did not redirect to the latest release on Github"
    return 2
  else
    echo "$NVM_LATEST_URL" | awk -F'/' '{print $NF}'
  fi
}

nvm_download() {
  if nvm_has "curl"; then
    curl $*
  elif nvm_has "wget"; then
    # Emulate curl with wget
    ARGS=$(echo "$*" | command sed -e 's/--progress-bar /--progress=bar /' \
                           -e 's/-L //' \
                           -e 's/-I /--server-response /' \
                           -e 's/-s /-q /' \
                           -e 's/-o /-O /' \
                           -e 's/-C - /-c /')
    eval wget $ARGS
  fi
}

nvm_has_system_node() {
  [ "$(nvm deactivate >/dev/null 2>&1 && command -v node)" != '' ]
}

nvm_has_system_iojs() {
  [ "$(nvm deactivate >/dev/null 2>&1 && command -v iojs)" != '' ]
}

# Make zsh glob matching behave same as bash
# This fixes the "zsh: no matches found" errors
if nvm_has "unsetopt"; then
  unsetopt nomatch 2>/dev/null
  NVM_CD_FLAGS="-q"
fi

# Auto detect the NVM_DIR when not set
if [ -z "$NVM_DIR" ]; then
  if [ -n "$BASH_SOURCE" ]; then
    NVM_SCRIPT_SOURCE="${BASH_SOURCE[0]}"
  fi
  export NVM_DIR=$(cd $NVM_CD_FLAGS $(dirname "${NVM_SCRIPT_SOURCE:-$0}") > /dev/null && \pwd)
fi
unset NVM_SCRIPT_SOURCE 2> /dev/null


# Setup mirror location if not already set
if [ -z "$NVM_NODEJS_ORG_MIRROR" ]; then
  export NVM_NODEJS_ORG_MIRROR="https://nodejs.org/dist"
fi

if [ -z "$NVM_IOJS_ORG_MIRROR" ]; then
  export NVM_IOJS_ORG_MIRROR="https://iojs.org/dist"
fi
if [ -z "$NVM_IOJS_ORG_VERSION_LISTING" ]; then
  export NVM_IOJS_ORG_VERSION_LISTING="$NVM_IOJS_ORG_MIRROR/index.tab"
fi

nvm_tree_contains_path() {
  local tree
  tree="$1"
  local node_path
  node_path="$2"

  if [ "@$tree@" = "@@" ] || [ "@$node_path@" = "@@" ]; then
    >&2 echo "both the tree and the node path are required"
    return 2
  fi

  local pathdir
  pathdir=$(dirname "$node_path")
  while [ "$pathdir" != "" ] && [ "$pathdir" != "." ] && [ "$pathdir" != "/" ] && [ "$pathdir" != "$tree" ]; do
    pathdir=$(dirname "$pathdir")
  done
  [ "$pathdir" = "$tree" ]
}

# Traverse up in directory tree to find containing folder
nvm_find_up() {
  local path
  path=$PWD
  while [ "$path" != "" ] && [ ! -f "$path/$1" ]; do
    path=${path%/*}
  done
  echo "$path"
}


nvm_find_nvmrc() {
  local dir
  dir="$(nvm_find_up '.nvmrc')"
  if [ -e "$dir/.nvmrc" ]; then
    echo "$dir/.nvmrc"
  fi
}

# Obtain nvm version from rc file
nvm_rc_version() {
  export NVM_RC_VERSION=''
  local NVMRC_PATH
  NVMRC_PATH="$(nvm_find_nvmrc)"
  if [ -e "$NVMRC_PATH" ]; then
    read NVM_RC_VERSION < "$NVMRC_PATH"
    echo "Found '$NVMRC_PATH' with version <$NVM_RC_VERSION>"
  else
    >&2 echo "No .nvmrc file found"
    return 1
  fi
}

nvm_version_greater() {
  local LHS
  LHS=$(nvm_normalize_version "$1")
  local RHS
  RHS=$(nvm_normalize_version "$2")
  [ $LHS -gt $RHS ];
}

nvm_version_greater_than_or_equal_to() {
  local LHS
  LHS=$(nvm_normalize_version "$1")
  local RHS
  RHS=$(nvm_normalize_version "$2")
  [ $LHS -ge $RHS ];
}

nvm_version_dir() {
  local NVM_WHICH_DIR
  NVM_WHICH_DIR="$1"
  if [ -z "$NVM_WHICH_DIR" ] || [ "_$NVM_WHICH_DIR" = "_new" ]; then
    echo "$NVM_DIR/versions/node"
  elif [ "_$NVM_WHICH_DIR" = "_iojs" ]; then
    echo "$NVM_DIR/versions/io.js"
  elif [ "_$NVM_WHICH_DIR" = "_old" ]; then
    echo "$NVM_DIR"
  else
    echo "unknown version dir" >&2
    return 3
  fi
}

nvm_alias_path() {
  echo "$(nvm_version_dir old)/alias"
}

nvm_version_path() {
  local VERSION
  VERSION="$1"
  if [ -z "$VERSION" ]; then
    echo "version is required" >&2
    return 3
  elif nvm_is_iojs_version "$VERSION"; then
    echo "$(nvm_version_dir iojs)/$(nvm_strip_iojs_prefix "$VERSION")"
  elif nvm_version_greater 0.12.0 "$VERSION"; then
    echo "$(nvm_version_dir old)/$VERSION"
  else
    echo "$(nvm_version_dir new)/$VERSION"
  fi
}

# Expand a version using the version cache
nvm_version() {
  local PATTERN
  PATTERN=$1
  local VERSION
  # The default version is the current one
  if [ -z "$PATTERN" ]; then
    PATTERN='current'
  fi

  if [ "$PATTERN" = "current" ]; then
    nvm_ls_current
    return $?
  fi

  case "_$PATTERN" in
    "_$(nvm_node_prefix)" | "_$(nvm_node_prefix)-")
      PATTERN="stable"
    ;;
  esac
  VERSION="$(nvm_ls "$PATTERN" | tail -n1)"
  if [ -z "$VERSION" ] || [ "_$VERSION" = "_N/A" ]; then
    echo "N/A"
    return 3;
  else
    echo "$VERSION"
  fi
}

nvm_remote_version() {
  local PATTERN
  PATTERN="$1"
  local VERSION
  if nvm_validate_implicit_alias "$PATTERN" 2> /dev/null ; then
    case "_$PATTERN" in
      "_$(nvm_iojs_prefix)")
        VERSION="$(nvm_ls_remote_iojs | tail -n1)"
      ;;
      *)
        VERSION="$(nvm_ls_remote "$PATTERN")"
      ;;
    esac
  else
    VERSION="$(nvm_remote_versions "$PATTERN" | tail -n1)"
  fi
  echo "$VERSION"
  if [ "_$VERSION" = '_N/A' ]; then
    return 3
  fi
}

nvm_remote_versions() {
  local NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local PATTERN
  PATTERN="$1"
  if [ "_$PATTERN" = "_io.js" ]; then
    PATTERN="$NVM_IOJS_PREFIX"
  fi
  case "_$PATTERN" in
    "_$NVM_IOJS_PREFIX")
      VERSIONS="$(nvm_ls_remote_iojs)"
    ;;
    "_$(nvm_node_prefix)")
      VERSIONS="$(nvm_ls_remote)"
    ;;
    *)
      if nvm_validate_implicit_alias "$PATTERN" 2> /dev/null ; then
        echo >&2 "Implicit aliases are not supported in nvm_remote_versions."
        return 1
      fi
      VERSIONS="$(echo "$(nvm_ls_remote "$PATTERN")
$(nvm_ls_remote_iojs "$PATTERN")" | command grep -v "N/A" | command sed '/^$/d')"
    ;;
  esac

  if [ -z "$VERSIONS" ]; then
    echo "N/A"
    return 3
  else
    echo "$VERSIONS"
  fi
}

nvm_is_valid_version() {
  if nvm_validate_implicit_alias "$1" 2> /dev/null; then
    return 0
  fi
  case "$1" in
    "$(nvm_iojs_prefix)" | "$(nvm_node_prefix)")
      return 0
    ;;
    *)
      local VERSION
      VERSION="$(nvm_strip_iojs_prefix "$1")"
      nvm_version_greater "$VERSION"
    ;;
  esac
}

nvm_normalize_version() {
  echo "$1" | command sed -e 's/^v//' | command awk -F. '{ printf("%d%06d%06d\n", $1,$2,$3); }'
}

nvm_ensure_version_prefix() {
  local NVM_VERSION
  NVM_VERSION="$(nvm_strip_iojs_prefix "$1" | command sed -e 's/^\([0-9]\)/v\1/g')"
  if nvm_is_iojs_version "$1"; then
    echo "$(nvm_add_iojs_prefix "$NVM_VERSION")"
  else
    echo "$NVM_VERSION"
  fi
}

nvm_format_version() {
  local VERSION
  VERSION="$(nvm_ensure_version_prefix "$1")"
  if [ "_$(nvm_num_version_groups "$VERSION")" != "_3" ]; then
    VERSION="$(echo "$VERSION" | command sed -e 's/\.*$/.0/')"
    nvm_format_version "$VERSION"
  else
    echo "$VERSION"
  fi
}

nvm_num_version_groups() {
  local VERSION
  VERSION="$1"
  if [ -z "$VERSION" ]; then
    echo "0"
    return
  fi
  local NVM_NUM_DOTS
  NVM_NUM_DOTS=$(echo "$VERSION" | command sed -e 's/^v//' | command sed -e 's/\.$//' | command sed -e 's/[^\.]//g')
  local NVM_NUM_GROUPS
  NVM_NUM_GROUPS=".$NVM_NUM_DOTS"
  echo "${#NVM_NUM_GROUPS}"
}

nvm_strip_path() {
  echo "$1" | command sed \
    -e "s#$NVM_DIR/[^/]*$2[^:]*:##g" \
    -e "s#:$NVM_DIR/[^/]*$2[^:]*##g" \
    -e "s#$NVM_DIR/[^/]*$2[^:]*##g" \
    -e "s#$NVM_DIR/versions/[^/]*/[^/]*$2[^:]*:##g" \
    -e "s#:$NVM_DIR/versions/[^/]*/[^/]*$2[^:]*##g" \
    -e "s#$NVM_DIR/versions/[^/]*/[^/]*$2[^:]*##g"
}

nvm_prepend_path() {
  if [ -z "$1" ]; then
    echo "$2"
  else
    echo "$2:$1"
  fi
}

nvm_binary_available() {
  # binaries started with node 0.8.6
  local FIRST_VERSION_WITH_BINARY
  FIRST_VERSION_WITH_BINARY="0.8.6"
  nvm_version_greater_than_or_equal_to "$(nvm_strip_iojs_prefix $1)" "$FIRST_VERSION_WITH_BINARY"
}

nvm_alias() {
  local ALIAS
  ALIAS="$1"
  if [ -z "$ALIAS" ]; then
    echo >&2 'An alias is required.'
    return 1
  fi

  local NVM_ALIAS_PATH
  NVM_ALIAS_PATH="$(nvm_alias_path)/$ALIAS"
  if [ ! -f "$NVM_ALIAS_PATH" ]; then
    echo >&2 'Alias does not exist.'
    return 2
  fi

  cat "$NVM_ALIAS_PATH"
}

nvm_ls_current() {
  local NVM_LS_CURRENT_NODE_PATH
  NVM_LS_CURRENT_NODE_PATH="$(command which node 2> /dev/null)"
  if [ $? -ne 0 ]; then
    echo 'none'
  elif nvm_tree_contains_path "$(nvm_version_dir iojs)" "$NVM_LS_CURRENT_NODE_PATH"; then
    echo "$(nvm_add_iojs_prefix $(iojs --version 2>/dev/null))"
  elif nvm_tree_contains_path "$NVM_DIR" "$NVM_LS_CURRENT_NODE_PATH"; then
    local VERSION
    VERSION="$(node --version 2>/dev/null)"
    if [ "$VERSION" = "v0.6.21-pre" ]; then
      echo "v0.6.21"
    else
      echo "$VERSION"
    fi
  else
    echo 'system'
  fi
}

nvm_resolve_alias() {
  if [ -z "$1" ]; then
    return 1
  fi

  local PATTERN
  PATTERN="$1"

  local ALIAS
  ALIAS="$PATTERN"
  local ALIAS_TEMP

  local SEEN_ALIASES
  SEEN_ALIASES="$ALIAS"
  while true; do
    ALIAS_TEMP="$(nvm_alias "$ALIAS" 2> /dev/null)"

    if [ -z "$ALIAS_TEMP" ]; then
      break
    fi

    if [ -n "$ALIAS_TEMP" ] \
      && printf "$SEEN_ALIASES" | command grep -e "^$ALIAS_TEMP$" > /dev/null; then
      ALIAS="∞"
      break
    fi

    SEEN_ALIASES="$SEEN_ALIASES\n$ALIAS_TEMP"
    ALIAS="$ALIAS_TEMP"
  done

  if [ -n "$ALIAS" ] && [ "_$ALIAS" != "_$PATTERN" ]; then
    if [ "_$ALIAS" = "_∞" ]; then
      echo "$ALIAS"
    else
      nvm_version "$ALIAS"
    fi
    return 0
  fi

  if nvm_validate_implicit_alias "$PATTERN" 2> /dev/null ; then
    local IMPLICIT
    IMPLICIT="$(nvm_print_implicit_alias local "$PATTERN" 2> /dev/null)"
    if [ -n "$IMPLICIT" ]; then
      nvm_version "$IMPLICIT"
      return $?
    fi
    return 3
  fi

  return 2
}

nvm_iojs_prefix() {
  echo "iojs"
}
nvm_node_prefix() {
  echo "node"
}

nvm_is_iojs_version() {
  [ "_$(echo "$1" | cut -c1-5)" = "_iojs-" ]
}

nvm_add_iojs_prefix() {
  command echo "$(nvm_iojs_prefix)-$(nvm_ensure_version_prefix "$(nvm_strip_iojs_prefix "$1")")"
}

nvm_strip_iojs_prefix() {
  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  if [ "_$1" = "_$NVM_IOJS_PREFIX" ]; then
    echo
  else
    echo "$1" | command sed "s/^$NVM_IOJS_PREFIX-//"
  fi
}

nvm_ls() {
  local PATTERN
  PATTERN="$1"
  local VERSIONS
  VERSIONS=''
  if [ "$PATTERN" = 'current' ]; then
    nvm_ls_current
    return
  fi

  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"
  local NVM_VERSION_DIR_IOJS
  NVM_VERSION_DIR_IOJS="$(nvm_version_dir iojs)"
  local NVM_VERSION_DIR_NEW
  NVM_VERSION_DIR_NEW="$(nvm_version_dir new)"
  local NVM_VERSION_DIR_OLD
  NVM_VERSION_DIR_OLD="$(nvm_version_dir old)"

  case "$PATTERN" in
    "$NVM_IOJS_PREFIX" | "$NVM_NODE_PREFIX" )
      PATTERN="$PATTERN-"
    ;;
    *)
      if nvm_resolve_alias "$PATTERN"; then
        return
      fi
      PATTERN=$(nvm_ensure_version_prefix $PATTERN)
    ;;
  esac
  # If it looks like an explicit version, don't do anything funny
  if [ "_$(echo "$PATTERN" | cut -c1-1)" = "_v" ] && [ "_$(nvm_num_version_groups "$PATTERN")" = "_3" ]; then
    if [ -d "$(nvm_version_path "$PATTERN")" ]; then
      VERSIONS="$PATTERN"
    elif [ -d "$(nvm_version_path "$(nvm_add_iojs_prefix "$PATTERN")")" ]; then
      VERSIONS="$(nvm_add_iojs_prefix "$PATTERN")"
    fi
  else
    case "$PATTERN" in
      "$NVM_IOJS_PREFIX-" | "$NVM_NODE_PREFIX-" | "system") ;;
      *)
        local NUM_VERSION_GROUPS
        NUM_VERSION_GROUPS="$(nvm_num_version_groups "$PATTERN")"
        if [ "_$NUM_VERSION_GROUPS" = "_2" ] || [ "_$NUM_VERSION_GROUPS" = "_1" ]; then
          PATTERN="$(echo "$PATTERN" | command sed -e 's/\.*$//g')."
        fi
      ;;
    esac

    local ZHS_HAS_SHWORDSPLIT_UNSET
    ZHS_HAS_SHWORDSPLIT_UNSET=1
    if nvm_has "setopt"; then
      ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
      setopt shwordsplit
    fi

    local NVM_DIRS_TO_TEST_AND_SEARCH
    local NVM_DIRS_TO_SEARCH
    local NVM_ADD_SYSTEM
    NVM_ADD_SYSTEM=false
    if nvm_is_iojs_version "$PATTERN"; then
      NVM_DIRS_TO_TEST_AND_SEARCH="$NVM_VERSION_DIR_IOJS"
      PATTERN="$(nvm_strip_iojs_prefix "$PATTERN")"
      if nvm_has_system_iojs; then
        NVM_ADD_SYSTEM=true
      fi
    elif [ "_$PATTERN" = "_$NVM_NODE_PREFIX-" ]; then
      NVM_DIRS_TO_TEST_AND_SEARCH="$NVM_VERSION_DIR_OLD $NVM_VERSION_DIR_NEW"
      PATTERN=''
      if nvm_has_system_node; then
        NVM_ADD_SYSTEM=true
      fi
    else
      NVM_DIRS_TO_TEST_AND_SEARCH="$NVM_VERSION_DIR_OLD $NVM_VERSION_DIR_NEW $NVM_VERSION_DIR_IOJS"
      if nvm_has_system_iojs || nvm_has_system_node; then
        NVM_ADD_SYSTEM=true
      fi
    fi
    for NVM_VERSION_DIR in $NVM_DIRS_TO_TEST_AND_SEARCH; do
      if [ -d "$NVM_VERSION_DIR" ]; then
        NVM_DIRS_TO_SEARCH="$NVM_VERSION_DIR $NVM_DIRS_TO_SEARCH"
      fi
    done

    if [ -z "$PATTERN" ]; then
      PATTERN='v'
    fi
    if [ -n "$NVM_DIRS_TO_SEARCH" ]; then
      VERSIONS="$(command find $NVM_DIRS_TO_SEARCH -maxdepth 1 -type d -name "$PATTERN*" \
        | command sed "s#$NVM_VERSION_DIR_IOJS/#"$NVM_IOJS_PREFIX"-#" \
        | command grep -v "$NVM_VERSION_DIR_IOJS" \
        | command sed "s#^$NVM_DIR/##" \
        | command grep -v -e '^versions$' \
        | command sed 's#^versions/##' \
        | sed -e "s/^v/$NVM_NODE_PREFIX-v/" \
        | sed -e "s#^\($NVM_IOJS_PREFIX\)[-/]v#\1.v#" | sed -e "s#^\($NVM_NODE_PREFIX\)[-/]v#\1.v#" \
        | command sort -t. -u -k 2.2,2n -k 3,3n -k 4,4n \
        | command sort -s -t- -k1.1,1.1 \
        | command sed "s/^\($NVM_IOJS_PREFIX\)\./\1-/" \
        | command sed "s/^$NVM_NODE_PREFIX\.//")"
    fi

    if [ $ZHS_HAS_SHWORDSPLIT_UNSET -eq 1 ] && nvm_has "unsetopt"; then
      unsetopt shwordsplit
    fi
  fi

  if [ "$NVM_ADD_SYSTEM" = true ]; then
    if [ -z "$PATTERN" ] || [ "_$PATTERN" = "_v" ]; then
      VERSIONS="$VERSIONS$(command printf '\n%s' 'system')"
    elif [ "$PATTERN" = 'system' ]; then
      VERSIONS="$(command printf '%s' 'system')"
    fi
  fi

  if [ -z "$VERSIONS" ]; then
    echo "N/A"
    return 3
  fi

  echo "$VERSIONS"
}

nvm_ls_remote() {
  local PATTERN
  PATTERN="$1"
  local VERSIONS
  local GREP_OPTIONS
  GREP_OPTIONS=''
  if nvm_validate_implicit_alias "$PATTERN" 2> /dev/null ; then
    PATTERN="$(nvm_ls_remote "$(nvm_print_implicit_alias remote "$PATTERN")" | tail -n1)"
  elif [ -n "$PATTERN" ]; then
    PATTERN="$(nvm_ensure_version_prefix "$PATTERN")"
  else
    PATTERN=".*"
  fi
  VERSIONS=`nvm_download -L -s $NVM_NODEJS_ORG_MIRROR/ -o - \
              | \egrep -o 'v[0-9]+\.[0-9]+\.[0-9]+' \
              | command grep -w "${PATTERN}" \
              | sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n`
  if [ -z "$VERSIONS" ]; then
    echo "N/A"
    return 3
  fi
  echo "$VERSIONS"
}

nvm_ls_remote_iojs() {
  local PATTERN
  PATTERN="$1"
  local VERSIONS
  if [ -n "$PATTERN" ]; then
    PATTERN="$(nvm_ensure_version_prefix $(nvm_strip_iojs_prefix "$PATTERN"))"
  else
    PATTERN=".*"
  fi
  VERSIONS="$(nvm_download -L -s $NVM_IOJS_ORG_VERSION_LISTING -o - \
    | command sed 1d \
    | command sed "s/^/$(nvm_iojs_prefix)-/" \
    | command cut -f1 \
    | command grep -w "$PATTERN" \
    | command sort)"
  if [ -z "$VERSIONS" ]; then
    echo "N/A"
    return 3
  fi
  echo "$VERSIONS"
}

nvm_checksum() {
  local NVM_CHECKSUM
  if nvm_has "sha1sum" && ! nvm_is_alias "sha1sum"; then
    NVM_CHECKSUM="$(command sha1sum "$1" | command awk '{print $1}')"
  elif nvm_has "sha1" && ! nvm_is_alias "sha1"; then
    NVM_CHECKSUM="$(command sha1 -q "$1")"
  elif nvm_has "shasum" && ! nvm_is_alias "shasum"; then
    NVM_CHECKSUM="$(shasum "$1" | command awk '{print $1}')"
  else
    echo "Unaliased sha1sum, sha1, or shasum not found." >&2
    return 2
  fi

  if [ "_$NVM_CHECKSUM" = "_$2" ]; then
    return
  elif [ -z "$2" ]; then
    echo 'Checksums empty' #missing in raspberry pi binary
    return
  else
    echo 'Checksums do not match.' >&2
    return 1
  fi
}

nvm_print_versions() {
  local VERSION
  local FORMAT
  local NVM_CURRENT
  NVM_CURRENT=$(nvm_ls_current)
  echo "$1" | while read VERSION; do
    if [ "_$VERSION" = "_$NVM_CURRENT" ]; then
      FORMAT='\033[0;32m-> %12s\033[0m'
    elif [ "$VERSION" = "system" ]; then
      FORMAT='\033[0;33m%15s\033[0m'
    elif [ -d "$(nvm_version_path "$VERSION" 2> /dev/null)" ]; then
      FORMAT='\033[0;34m%15s\033[0m'
    else
      FORMAT='%15s'
    fi
    printf "$FORMAT\n" $VERSION
  done
}

nvm_validate_implicit_alias() {
  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"

  case "$1" in
    "stable" | "unstable" | "$NVM_IOJS_PREFIX" | "$NVM_NODE_PREFIX" )
      return
    ;;
    *)
      echo "Only implicit aliases 'stable', 'unstable', '$NVM_IOJS_PREFIX', and '$NVM_NODE_PREFIX' are supported." >&2
      return 1
    ;;
  esac
}

nvm_print_implicit_alias() {
  if [ "_$1" != "_local" ] && [ "_$1" != "_remote" ]; then
    echo "nvm_print_implicit_alias must be specified with local or remote as the first argument." >&2
    return 1
  fi

  if ! nvm_validate_implicit_alias "$2"; then
    return 2
  fi

  local ZHS_HAS_SHWORDSPLIT_UNSET

  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"
  local NVM_COMMAND
  local LAST_TWO
  case "$2" in
    "$NVM_IOJS_PREFIX")
      NVM_COMMAND="nvm_ls_remote_iojs"
      if [ "_$1" = "_local" ]; then
        NVM_COMMAND="nvm_ls iojs"
      fi

      ZHS_HAS_SHWORDSPLIT_UNSET=1
      if nvm_has "setopt"; then
        ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
        setopt shwordsplit
      fi

      local NVM_IOJS_VERSION
      NVM_IOJS_VERSION="$($NVM_COMMAND | sed "s/^"$NVM_IOJS_PREFIX"-//" | command grep -e '^v' | cut -c2- | cut -d . -f 1,2 | uniq | tail -1)"
      local EXIT_CODE
      EXIT_CODE="$?"

      if [ $ZHS_HAS_SHWORDSPLIT_UNSET -eq 1 ] && nvm_has "unsetopt"; then
        unsetopt shwordsplit
      fi

      echo "$(nvm_add_iojs_prefix "$NVM_IOJS_VERSION")"
      return $EXIT_CODE
    ;;
    "$NVM_NODE_PREFIX")
      echo "stable"
      return
    ;;
    *)
      NVM_COMMAND="nvm_ls_remote"
      if [ "_$1" = "_local" ]; then
        NVM_COMMAND="nvm_ls node"
      fi

      ZHS_HAS_SHWORDSPLIT_UNSET=1
      if nvm_has "setopt"; then
        ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
        setopt shwordsplit
      fi

      LAST_TWO=$($NVM_COMMAND | command grep -e '^v' | cut -c2- | cut -d . -f 1,2 | uniq)

      if [ $ZHS_HAS_SHWORDSPLIT_UNSET -eq 1 ] && nvm_has "unsetopt"; then
        unsetopt shwordsplit
      fi
    ;;
  esac
  local MINOR
  local STABLE
  local UNSTABLE
  local MOD

  ZHS_HAS_SHWORDSPLIT_UNSET=1
  if nvm_has "setopt"; then
    ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
    setopt shwordsplit
  fi
  for MINOR in $LAST_TWO; do
    MOD=$(expr "$(nvm_normalize_version "$MINOR")" \/ 1000000 \% 2)
    if [ $MOD -eq 0 ]; then
      STABLE="$MINOR"
    elif [ $MOD -eq 1 ]; then
      UNSTABLE="$MINOR"
    fi
  done
  if [ $ZHS_HAS_SHWORDSPLIT_UNSET -eq 1 ] && nvm_has "unsetopt"; then
    unsetopt shwordsplit
  fi

  if [ "_$2" = "_stable" ]; then
    echo $STABLE
  elif [ "_$2" = "_unstable" ]; then
    echo $UNSTABLE
  fi
}

nvm_get_os() {
  local NVM_UNAME
  NVM_UNAME="$(uname -a)"
  local NVM_OS
  case "$NVM_UNAME" in
    Linux\ *) NVM_OS=linux ;;
    Darwin\ *) NVM_OS=darwin ;;
    SunOS\ *) NVM_OS=sunos ;;
    FreeBSD\ *) NVM_OS=freebsd ;;
  esac
  echo "$NVM_OS"
}

nvm_get_arch() {
  local NVM_UNAME
  NVM_UNAME="$(uname -a)"
  local NVM_ARCH
  case "$NVM_UNAME" in
    *x86_64*) NVM_ARCH=x64 ;;
    *i*86*) NVM_ARCH=x86 ;;
    *armv6l*) NVM_ARCH=arm-pi ;;
    *) NVM_ARCH="$(uname -m)" ;;
  esac
  echo "$NVM_ARCH"
}

nvm_install_iojs_binary() {
  local PREFIXED_VERSION
  PREFIXED_VERSION="$1"
  local REINSTALL_PACKAGES_FROM
  REINSTALL_PACKAGES_FROM="$2"

  if ! nvm_is_iojs_version "$PREFIXED_VERSION"; then
    echo 'nvm_install_iojs_binary requires an iojs-prefixed version.' >&2
    return 10
  fi

  local VERSION
  VERSION="$(nvm_strip_iojs_prefix "$PREFIXED_VERSION")"
  local VERSION_PATH
  VERSION_PATH="$(nvm_version_path "$PREFIXED_VERSION")"
  local NVM_OS
  NVM_OS="$(nvm_get_os)"
  local t
  local url
  local sum

  if [ -n "$NVM_OS" ]; then
    if nvm_binary_available "$VERSION"; then
      t="$VERSION-$NVM_OS-$(nvm_get_arch)"
      url="$NVM_IOJS_ORG_MIRROR/$VERSION/$(nvm_iojs_prefix)-${t}.tar.gz"
      sum="$(nvm_download -L -s $NVM_IOJS_ORG_MIRROR/$VERSION/SHASUMS256.txt -o - | command grep $(nvm_iojs_prefix)-${t}.tar.gz | command awk '{print $1}')"
      local tmpdir
      tmpdir="$NVM_DIR/bin/iojs-${t}"
      local tmptarball
      tmptarball="$tmpdir/iojs-${t}.tar.gz"
      if (
        command mkdir -p "$tmpdir" && \
        nvm_download -L -C - --progress-bar $url -o "$tmptarball" && \
        echo "WARNING: checksums are currently disabled for io.js" >&2 && \
        # nvm_checksum "$tmptarball" $sum && \
        command tar -xzf "$tmptarball" -C "$tmpdir" --strip-components 1 && \
        command rm -f "$tmptarball" && \
        command mkdir -p "$VERSION_PATH" && \
        command mv "$tmpdir"/* "$VERSION_PATH"
      ); then
        return 0
      else
        echo "Binary download failed, trying source." >&2
        command rm -rf "$tmptarball" "$tmpdir"
        return 1
      fi
    fi
  fi
  return 2
}

nvm_install_node_binary() {
  local VERSION
  VERSION="$1"
  local REINSTALL_PACKAGES_FROM
  REINSTALL_PACKAGES_FROM="$2"

  if nvm_is_iojs_version "$PREFIXED_VERSION"; then
    echo 'nvm_install_node_binary does not allow an iojs-prefixed version.' >&2
    return 10
  fi

  local VERSION_PATH
  VERSION_PATH="$(nvm_version_path "$VERSION")"
  local NVM_OS
  NVM_OS="$(nvm_get_os)"
  local t
  local url
  local sum

  if [ -n "$NVM_OS" ]; then
    if nvm_binary_available "$VERSION"; then
      t="$VERSION-$NVM_OS-$(nvm_get_arch)"
      url="$NVM_NODEJS_ORG_MIRROR/$VERSION/node-${t}.tar.gz"
      sum=`nvm_download -L -s $NVM_NODEJS_ORG_MIRROR/$VERSION/SHASUMS.txt -o - | command grep node-${t}.tar.gz | command awk '{print $1}'`
      local tmpdir
      tmpdir="$NVM_DIR/bin/node-${t}"
      local tmptarball
      tmptarball="$tmpdir/node-${t}.tar.gz"
      if (
        command mkdir -p "$tmpdir" && \
        nvm_download -L -C - --progress-bar $url -o "$tmptarball" && \
        nvm_checksum "$tmptarball" $sum && \
        command tar -xzf "$tmptarball" -C "$tmpdir" --strip-components 1 && \
        command rm -f "$tmptarball" && \
        command mkdir -p "$VERSION_PATH" && \
        command mv "$tmpdir"/* "$VERSION_PATH"
      ); then
        return 0
      else
        echo "Binary download failed, trying source." >&2
        command rm -rf "$tmptarball" "$tmpdir"
        return 1
      fi
    fi
  fi
  return 2
}

nvm_install_node_source() {
  local VERSION
  VERSION="$1"
  local REINSTALL_PACKAGES_FROM
  REINSTALL_PACKAGES_FROM="$2"
  local ADDITIONAL_PARAMETERS
  ADDITIONAL_PARAMETERS="$3"

  if [ -n "$ADDITIONAL_PARAMETERS" ]; then
    echo "Additional options while compiling: $ADDITIONAL_PARAMETERS"
  fi

  local VERSION_PATH
  VERSION_PATH="$(nvm_version_path "$VERSION")"
  local NVM_OS
  NVM_OS="$(nvm_get_os)"

  local tarball
  tarball=''
  local sum
  sum=''
  local make
  make='make'
  if [ "_$NVM_OS" = "_freebsd" ]; then
    make='gmake'
    MAKE_CXX="CXX=c++"
  fi
  local tmpdir
  tmpdir="$NVM_DIR/src"
  local tmptarball
  tmptarball="$tmpdir/node-$VERSION.tar.gz"

  if [ "`nvm_download -L -s -I "$NVM_NODEJS_ORG_MIRROR/$VERSION/node-$VERSION.tar.gz" -o - 2>&1 | command grep '200 OK'`" != '' ]; then
    tarball="$NVM_NODEJS_ORG_MIRROR/$VERSION/node-$VERSION.tar.gz"
    sum=`nvm_download -L -s $NVM_NODEJS_ORG_MIRROR/$VERSION/SHASUMS.txt -o - | command grep "node-$VERSION.tar.gz" | command awk '{print $1}'`
  elif [ "`nvm_download -L -s -I "$NVM_NODEJS_ORG_MIRROR/node-$VERSION.tar.gz" -o - | command grep '200 OK'`" != '' ]; then
    tarball="$NVM_NODEJS_ORG_MIRROR/node-$VERSION.tar.gz"
  fi

  if (
    [ -n "$tarball" ] && \
    command mkdir -p "$tmpdir" && \
    nvm_download -L --progress-bar $tarball -o "$tmptarball" && \
    nvm_checksum "$tmptarball" $sum && \
    command tar -xzf "$tmptarball" -C "$tmpdir" && \
    cd "$tmpdir/node-$VERSION" && \
    ./configure --prefix="$VERSION_PATH" $ADDITIONAL_PARAMETERS && \
    $make $MAKE_CXX && \
    command rm -f "$VERSION_PATH" 2>/dev/null && \
    $make $MAKE_CXX install
    )
  then
    if nvm use "$VERSION" && [ ! -z "$REINSTALL_PACKAGES_FROM" ] && [ "_$REINSTALL_PACKAGES_FROM" != "_N/A" ]; then
      nvm reinstall-packages "$REINSTALL_PACKAGES_FROM"
    fi
    if ! nvm_has "npm" ; then
      echo "Installing npm..."
      if nvm_version_greater 0.2.0 "$VERSION"; then
        echo "npm requires node v0.2.3 or higher" >&2
      elif nvm_version_greater_than_or_equal_to "$VERSION" 0.2.0; then
        if nvm_version_greater 0.2.3 "$VERSION"; then
          echo "npm requires node v0.2.3 or higher" >&2
        else
          nvm_download -L https://npmjs.org/install.sh -o - | clean=yes npm_install=0.2.19 sh
        fi
      else
        nvm_download -L https://npmjs.org/install.sh -o - | clean=yes sh
      fi
    fi
  else
    echo "nvm: install $VERSION failed!" >&2
    return 1
  fi

  return $?
}

nvm() {
  if [ $# -lt 1 ]; then
    nvm help
    return
  fi

  local GREP_OPTIONS
  GREP_OPTIONS=''

  # initialize local variables
  local VERSION
  local ADDITIONAL_PARAMETERS
  local ALIAS

  case $1 in
    "help" )
      echo
      echo "Node Version Manager"
      echo
      echo "Usage:"
      echo "  nvm help                              Show this message"
      echo "  nvm --version                         Print out the latest released version of nvm"
      echo "  nvm install [-s] <version>            Download and install a <version>, [-s] from source. Uses .nvmrc if available"
      echo "  nvm uninstall <version>               Uninstall a version"
      echo "  nvm use <version>                     Modify PATH to use <version>. Uses .nvmrc if available"
      echo "  nvm run <version> [<args>]            Run <version> with <args> as arguments. Uses .nvmrc if available for <version>"
      echo "  nvm current                           Display currently activated version"
      echo "  nvm ls                                List installed versions"
      echo "  nvm ls <version>                      List versions matching a given description"
      echo "  nvm ls-remote                         List remote versions available for install"
      echo "  nvm deactivate                        Undo effects of \`nvm\` on current shell"
      echo "  nvm alias [<pattern>]                 Show all aliases beginning with <pattern>"
      echo "  nvm alias <name> <version>            Set an alias named <name> pointing to <version>"
      echo "  nvm unalias <name>                    Deletes the alias named <name>"
      echo "  nvm reinstall-packages <version>      Reinstall global \`npm\` packages contained in <version> to current version"
      echo "  nvm unload                            Unload \`nvm\` from shell"
      echo "  nvm which [<version>]                 Display path to installed node version. Uses .nvmrc if available"
      echo
      echo "Example:"
      echo "  nvm install v0.10.32                  Install a specific version number"
      echo "  nvm use 0.10                          Use the latest available 0.10.x release"
      echo "  nvm run 0.10.32 app.js                Run app.js using node v0.10.32"
      echo "  nvm exec 0.10.32 node app.js          Run \`node app.js\` with the PATH pointing to node v0.10.32"
      echo "  nvm alias default 0.10.32             Set default node version on a shell"
      echo
      echo "Note:"
      echo "  to remove, delete, or uninstall nvm - just remove ~/.nvm, ~/.npm, and ~/.bower folders"
      echo
    ;;

    "install" | "i" )
      local nobinary
      local version_not_provided
      version_not_provided=0
      local provided_version
      local NVM_OS
      NVM_OS="$(nvm_get_os)"

      if ! nvm_has "curl" && ! nvm_has "wget"; then
        echo 'nvm needs curl or wget to proceed.' >&2;
        return 1
      fi

      if [ $# -lt 2 ]; then
        version_not_provided=1
        nvm_rc_version
        if [ -z "$NVM_RC_VERSION" ]; then
          nvm help
          return
        fi
      fi

      shift

      nobinary=0
      if [ "_$1" = "_-s" ]; then
        nobinary=1
        shift
      fi

      provided_version="$1"

      if [ -z "$provided_version" ]; then
        if [ $version_not_provided -ne 1 ]; then
          nvm_rc_version
        fi
        provided_version="$NVM_RC_VERSION"
      else
        shift
      fi

      VERSION="$(nvm_remote_version "$provided_version")"

      if [ "_$VERSION" = "_N/A" ]; then
        echo "Version '$provided_version' not found - try \`nvm ls-remote\` to browse available versions." >&2
        return 3
      fi

      ADDITIONAL_PARAMETERS=''
      local PROVIDED_REINSTALL_PACKAGES_FROM
      local REINSTALL_PACKAGES_FROM

      while [ $# -ne 0 ]
      do
        if [ "_$(echo "$1" | command cut -c 1-26)" = "_--reinstall-packages-from=" ]; then
          PROVIDED_REINSTALL_PACKAGES_FROM="$(echo "$1" | command cut -c 27-)"
          REINSTALL_PACKAGES_FROM="$(nvm_version "$PROVIDED_REINSTALL_PACKAGES_FROM")"
        elif [ "_$(echo "$1" | command cut -c 1-21)" = "_--copy-packages-from=" ]; then
          PROVIDED_REINSTALL_PACKAGES_FROM="$(echo "$1" | command cut -c 22-)"
          REINSTALL_PACKAGES_FROM="$(nvm_version "$PROVIDED_REINSTALL_PACKAGES_FROM")"
        else
          ADDITIONAL_PARAMETERS="$ADDITIONAL_PARAMETERS $1"
        fi
        shift
      done

      if [ "_$(nvm_ensure_version_prefix "$PROVIDED_REINSTALL_PACKAGES_FROM")" = "_$VERSION" ]; then
        echo "You can't reinstall global packages from the same version of node you're installing." >&2
        return 4
      elif [ ! -z "$PROVIDED_REINSTALL_PACKAGES_FROM" ] && [ "_$REINSTALL_PACKAGES_FROM" = "_N/A" ]; then
        echo "If --reinstall-packages-from is provided, it must point to an installed version of node." >&2
        return 5
      fi

      local NVM_IOJS
      if nvm_is_iojs_version "$VERSION"; then
        NVM_IOJS=true
      fi

      local VERSION_PATH
      VERSION_PATH="$(nvm_version_path "$VERSION")"
      if [ -d "$VERSION_PATH" ]; then
        echo "$VERSION is already installed." >&2
        if nvm use "$VERSION" && [ ! -z "$REINSTALL_PACKAGES_FROM" ] && [ "_$REINSTALL_PACKAGES_FROM" != "_N/A" ]; then
          nvm reinstall-packages "$REINSTALL_PACKAGES_FROM"
        fi
        return $?
      fi

      if [ "_$NVM_OS" = "_freebsd" ]; then
        # node.js and io.js do not have a FreeBSD binary
        nobinary=1
      elif [ "_$NVM_OS" = "_sunos" ] && [ "$NVM_IOJS" = true ]; then
        # io.js does not have a SunOS binary
        nobinary=1
      fi
      # skip binary install if "nobinary" option specified.
      if [ $nobinary -ne 1 ] && nvm_binary_available "$VERSION"; then
        local NVM_INSTALL_SUCCESS
        if [ "$NVM_IOJS" = true ] && nvm_install_iojs_binary "$VERSION" "$REINSTALL_PACKAGES_FROM"; then
          NVM_INSTALL_SUCCESS=true
        elif [ "$NVM_IOJS" != true ] && nvm_install_node_binary "$VERSION" "$REINSTALL_PACKAGES_FROM"; then
          NVM_INSTALL_SUCCESS=true
        fi

        if [ "$NVM_INSTALL_SUCCESS" = true ] \
          && nvm use "$VERSION" \
          && [ ! -z "$REINSTALL_PACKAGES_FROM" ] \
          && [ "_$REINSTALL_PACKAGES_FROM" != "_N/A" ]; then
          nvm reinstall-packages "$REINSTALL_PACKAGES_FROM"
        fi
        return $?
      fi

      if [ "$NVM_IOJS" = true ]; then
        # nvm_install_iojs_source "$VERSION" "$REINSTALL_PACKAGES_FROM" "$ADDITIONAL_PARAMETERS"
        echo "Installing iojs from source is not currently supported" >&2
        return 105
      else
        nvm_install_node_source "$VERSION" "$REINSTALL_PACKAGES_FROM" "$ADDITIONAL_PARAMETERS"
      fi
    ;;
    "uninstall" )
      [ $# -ne 2 ] && nvm help && return

      local PATTERN
      PATTERN="$2"
      case "_$PATTERN" in
        "_$(nvm_iojs_prefix)" | "_$(nvm_iojs_prefix)-" \
        | "_$(nvm_node_prefix)" | "_$(nvm_node_prefix)-")
          VERSION="$(nvm_version "$PATTERN")"
        ;;
        *)
          VERSION="$(nvm_version "$PATTERN")"
        ;;
      esac
      if [ "_$VERSION" = "_$(nvm_ls_current)" ]; then
        if nvm_is_iojs_version "$VERSION"; then
          echo "nvm: Cannot uninstall currently-active io.js version, $VERSION (inferred from $PATTERN)." >&2
        else
          echo "nvm: Cannot uninstall currently-active node version, $VERSION (inferred from $PATTERN)." >&2
        fi
        return 1
      fi

      local VERSION_PATH
      VERSION_PATH="$(nvm_version_path "$VERSION")"
      if [ ! -d "$VERSION_PATH" ]; then
        echo "$VERSION version is not installed..." >&2
        return;
      fi

      t="$VERSION-$(nvm_get_os)-$(nvm_get_arch)"

      local NVM_PREFIX
      local NVM_SUCCESS_MSG
      if nvm_is_iojs_version "$VERSION"; then
        NVM_PREFIX="$(nvm_iojs_prefix)"
        NVM_SUCCESS_MSG="Uninstalled io.js $(nvm_strip_iojs_prefix $VERSION)"
      else
        NVM_PREFIX="$(nvm_node_prefix)"
        NVM_SUCCESS_MSG="Uninstalled node $VERSION"
      fi
      # Delete all files related to target version.
      command rm -rf "$NVM_DIR/src/$NVM_PREFIX-$VERSION" \
             "$NVM_DIR/src/$NVM_PREFIX-$VERSION.tar.gz" \
             "$NVM_DIR/bin/$NVM_PREFIX-${t}" \
             "$NVM_DIR/bin/$NVM_PREFIX-${t}.tar.gz" \
             "$VERSION_PATH" 2>/dev/null
      echo "$NVM_SUCCESS_MSG"

      # rm any aliases that point to uninstalled version.
      for ALIAS in `command grep -l $VERSION "$(nvm_alias_path)/*" 2>/dev/null`
      do
        nvm unalias "$(command basename "$ALIAS")"
      done
    ;;
    "deactivate" )
      local NEWPATH
      NEWPATH="$(nvm_strip_path "$PATH" "/bin")"
      if [ "_$PATH" = "_$NEWPATH" ]; then
        echo "Could not find $NVM_DIR/*/bin in \$PATH" >&2
      else
        export PATH="$NEWPATH"
        hash -r
        echo "$NVM_DIR/*/bin removed from \$PATH"
      fi

      NEWPATH="$(nvm_strip_path "$MANPATH" "/share/man")"
      if [ "_$MANPATH" = "_$NEWPATH" ]; then
        echo "Could not find $NVM_DIR/*/share/man in \$MANPATH" >&2
      else
        export MANPATH="$NEWPATH"
        echo "$NVM_DIR/*/share/man removed from \$MANPATH"
      fi

      NEWPATH="$(nvm_strip_path "$NODE_PATH" "/lib/node_modules")"
      if [ "_$NODE_PATH" != "_$NEWPATH" ]; then
        export NODE_PATH="$NEWPATH"
        echo "$NVM_DIR/*/lib/node_modules removed from \$NODE_PATH"
      fi
    ;;
    "use" )
      if [ $# -eq 0 ]; then
        nvm help
        return 127
      fi

      if [ $# -eq 1 ]; then
        nvm_rc_version
        if [ -n "$NVM_RC_VERSION" ]; then
          VERSION="$(nvm_version "$NVM_RC_VERSION")"
        fi
      else
        local NVM_IOJS_PREFIX
        NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
        local NVM_NODE_PREFIX
        NVM_NODE_PREFIX="$(nvm_node_prefix)"
        case "_$2" in
          "_$NVM_IOJS_PREFIX" | "_io.js")
            VERSION="$(nvm_version $NVM_IOJS_PREFIX)"
          ;;
          "_system")
            VERSION="system"
          ;;
          *)
            VERSION="$(nvm_version "$2")"
          ;;
        esac
      fi

      if [ -z "$VERSION" ]; then
        nvm help
        return 127
      fi

      if [ "_$VERSION" = '_system' ]; then
        if nvm_has_system_node && nvm deactivate >/dev/null 2>&1; then
          echo "Now using system version of node: $(node -v 2>/dev/null)."
          return
        elif nvm_has_system_iojs && nvm deactivate >/dev/null 2>&1; then
          echo "Now using system version of io.js: $(iojs --version 2>/dev/null)."
          return
        else
          echo "System version of node not found." >&2
          return 127
        fi
      elif [ "_$VERSION" = "_∞" ]; then
        echo "The alias \"$2\" leads to an infinite loop. Aborting." >&2
        return 8
      fi

      local NVM_VERSION_DIR
      NVM_VERSION_DIR="$(nvm_version_path "$VERSION")"
      if [ ! -d "$NVM_VERSION_DIR" ]; then
        echo "$VERSION version is not installed yet" >&2
        return 1
      fi
      # Strip other version from PATH
      PATH="$(nvm_strip_path "$PATH" "/bin")"
      # Prepend current version
      PATH="$(nvm_prepend_path "$PATH" "$NVM_VERSION_DIR/bin")"
      if nvm_has manpath; then
        if [ -z "$MANPATH" ]; then
          MANPATH=$(manpath)
        fi
        # Strip other version from MANPATH
        MANPATH="$(nvm_strip_path "$MANPATH" "/share/man")"
        # Prepend current version
        MANPATH="$(nvm_prepend_path "$MANPATH" "$NVM_VERSION_DIR/share/man")"
        export MANPATH
      fi
      export PATH
      hash -r
      export NVM_PATH="$NVM_VERSION_DIR/lib/node"
      export NVM_BIN="$NVM_VERSION_DIR/bin"
      if [ "$NVM_SYMLINK_CURRENT" = true ]; then
        command rm -f "$NVM_DIR/current" && ln -s "$NVM_VERSION_DIR" "$NVM_DIR/current"
      fi
      if nvm_is_iojs_version "$VERSION"; then
        echo "Now using io.js $(nvm_strip_iojs_prefix "$VERSION")"
      else
        echo "Now using node $VERSION"
      fi
    ;;
    "run" )
      local provided_version
      local has_checked_nvmrc
      has_checked_nvmrc=0
      # run given version of node
      shift
      if [ $# -lt 1 ]; then
        nvm_rc_version && has_checked_nvmrc=1
        if [ -n "$NVM_RC_VERSION" ]; then
          VERSION="$(nvm_version "$NVM_RC_VERSION")"
        else
          VERSION='N/A'
        fi
        if [ $VERSION = "N/A" ]; then
          nvm help
          return 127
        fi
      fi

      provided_version=$1
      if [ -n "$provided_version" ]; then
        VERSION="$(nvm_version "$provided_version")"
        if [ "_$VERSION" = "_N/A" ] && ! nvm_is_valid_version "$provided_version"; then
          provided_version=''
          if [ $has_checked_nvmrc -ne 1 ]; then
            nvm_rc_version && has_checked_nvmrc=1
          fi
          VERSION="$(nvm_version "$NVM_RC_VERSION")"
        else
          shift
        fi
      fi

      local NVM_IOJS
      if nvm_is_iojs_version "$VERSION"; then
        NVM_IOJS=true
      fi

      local ARGS
      ARGS="$@"
      local OUTPUT
      local EXIT_CODE

      local ZHS_HAS_SHWORDSPLIT_UNSET
      ZHS_HAS_SHWORDSPLIT_UNSET=1
      if nvm_has "setopt"; then
        ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
        setopt shwordsplit
      fi
      if [ "_$VERSION" = "_N/A" ]; then
        echo "$(nvm_ensure_version_prefix "$provided_version") is not installed yet" >&2
        EXIT_CODE=1
      elif [ "$NVM_IOJS" = true ]; then
        echo "Running io.js $(nvm_strip_iojs_prefix "$VERSION")"
        OUTPUT="$(nvm use "$VERSION" >/dev/null && iojs $ARGS)"
        EXIT_CODE="$?"
      else
        echo "Running node $VERSION"
        OUTPUT="$(nvm use "$VERSION" >/dev/null && node $ARGS)"
        EXIT_CODE="$?"
      fi
      if [ $ZHS_HAS_SHWORDSPLIT_UNSET -eq 1 ] && nvm_has "unsetopt"; then
        unsetopt shwordsplit
      fi
      if [ -n "$OUTPUT" ]; then
        echo "$OUTPUT"
      fi
      return $EXIT_CODE
    ;;
    "exec" )
      shift

      local provided_version
      provided_version="$1"
      if [ -n "$provided_version" ]; then
        VERSION="$(nvm_version "$provided_version")"
        if [ "_$VERSION" = "_N/A" ]; then
          provided_version=''
          nvm_rc_version
          VERSION="$(nvm_version "$NVM_RC_VERSION")"
        else
          shift
        fi
      fi

      local NVM_VERSION_DIR
      NVM_VERSION_DIR="$(nvm_version_path "$VERSION")"
      if [ ! -d "$NVM_VERSION_DIR" ]; then
        echo "$VERSION version is not installed yet" >&2
        return 1
      fi
      echo "Running node $VERSION"
      NODE_VERSION="$VERSION" $NVM_DIR/nvm-exec "$@"
    ;;
    "ls" | "list" )
      local NVM_LS_OUTPUT
      local NVM_LS_EXIT_CODE
      NVM_LS_OUTPUT=$(nvm_ls "$2")
      NVM_LS_EXIT_CODE=$?
      nvm_print_versions "$NVM_LS_OUTPUT"
      if [ $# -eq 1 ]; then
        nvm alias
      fi
      return $NVM_LS_EXIT_CODE
    ;;
    "ls-remote" | "list-remote" )
      local PATTERN
      PATTERN="$2"
      local NVM_FLAVOR
      case "_$PATTERN" in
        "_$(nvm_iojs_prefix)" | "_$(nvm_node_prefix)" )
          NVM_FLAVOR="$PATTERN"
          PATTERN="$3"
        ;;
      esac

      local NVM_LS_REMOTE_EXIT_CODE
      NVM_LS_REMOTE_EXIT_CODE=0
      local NVM_LS_REMOTE_OUTPUT
      NVM_LS_REMOTE_OUTPUT=''
      if [ "_$NVM_FLAVOR" != "_$(nvm_iojs_prefix)" ]; then
        NVM_LS_REMOTE_OUTPUT=$(nvm_ls_remote "$PATTERN")
        NVM_LS_REMOTE_EXIT_CODE=$?
      fi

      local NVM_LS_REMOTE_IOJS_EXIT_CODE
      NVM_LS_REMOTE_IOJS_EXIT_CODE=0
      local NVM_LS_REMOTE_IOJS_OUTPUT
      NVM_LS_REMOTE_IOJS_OUTPUT=''
      if [ "_$NVM_FLAVOR" != "_$(nvm_node_prefix)" ]; then
        NVM_LS_REMOTE_IOJS_OUTPUT=$(nvm_ls_remote_iojs "$PATTERN")
        NVM_LS_REMOTE_IOJS_EXIT_CODE=$?
      fi

      local NVM_OUTPUT
      NVM_OUTPUT="$(echo "$NVM_LS_REMOTE_OUTPUT
$NVM_LS_REMOTE_IOJS_OUTPUT" | command grep -v "N/A" | sed '/^$/d')"
      if [ -n "$NVM_OUTPUT" ]; then
        nvm_print_versions "$NVM_OUTPUT"
        return $NVM_LS_REMOTE_EXIT_CODE || $NVM_LS_REMOTE_IOJS_EXIT_CODE
      else
        nvm_print_versions "N/A"
        return 3
      fi
    ;;
    "current" )
      nvm_version current
    ;;
    "which" )
      if [ $# -eq 1 ]; then
        nvm_rc_version
        if [ -n "$NVM_RC_VERSION" ]; then
          VERSION=$(nvm_version "$NVM_RC_VERSION")
        fi
      elif [ "_$2" != '_system' ]; then
        VERSION="$(nvm_version "$2")"
      else
        VERSION="$2"
      fi
      if [ -z "$VERSION" ]; then
        nvm help
        return 127
      fi

      if [ "_$VERSION" = '_system' ]; then
        if nvm_has_system_iojs >/dev/null 2>&1 || nvm_has_system_node >/dev/null 2>&1; then
          local NVM_BIN
          NVM_BIN="$(nvm use system >/dev/null 2>&1 && command which node)"
          if [ -n "$NVM_BIN" ]; then
            echo "$NVM_BIN"
            return
          else
            return 1
          fi
        else
          echo "System version of node not found." >&2
          return 127
        fi
      elif [ "_$VERSION" = "_∞" ]; then
        echo "The alias \"$2\" leads to an infinite loop. Aborting." >&2
        return 8
      fi

      local NVM_VERSION_DIR
      NVM_VERSION_DIR="$(nvm_version_path "$VERSION")"
      if [ ! -d "$NVM_VERSION_DIR" ]; then
        echo "$VERSION version is not installed yet" >&2
        return 1
      fi
      echo "$NVM_VERSION_DIR/bin/node"
    ;;
    "alias" )
      local NVM_ALIAS_DIR
      NVM_ALIAS_DIR="$(nvm_alias_path)"
      command mkdir -p "$NVM_ALIAS_DIR"
      if [ $# -le 2 ]; then
        local DEST
        for ALIAS_PATH in "$NVM_ALIAS_DIR"/"$2"*; do
          ALIAS="$(command basename "$ALIAS_PATH")"
          DEST="$(nvm_alias "$ALIAS" 2> /dev/null)"
          if [ -n "$DEST" ]; then
            VERSION="$(nvm_version "$DEST")"
            if [ "_$DEST" = "_$VERSION" ]; then
              echo "$ALIAS -> $DEST"
            else
              echo "$ALIAS -> $DEST (-> $VERSION)"
            fi
          fi
        done

        for ALIAS in "$(nvm_node_prefix)" "stable" "unstable" "$(nvm_iojs_prefix)"; do
          if [ ! -f "$NVM_ALIAS_DIR/$ALIAS" ]; then
            if [ $# -lt 2 ] || [ "~$ALIAS" = "~$2" ]; then
              DEST="$(nvm_print_implicit_alias local "$ALIAS")"
              if [ "_$DEST" != "_" ]; then
                VERSION="$(nvm_version "$DEST")"
                echo "$ALIAS -> $DEST (-> $VERSION) (default)"
              fi
            fi
          fi
        done
        return
      fi
      if [ -z "$3" ]; then
        command rm -f "$NVM_ALIAS_DIR/$2"
        echo "$2 -> *poof*"
        return
      fi
      VERSION="$(nvm_version "$3")"
      if [ $? -ne 0 ]; then
        echo "! WARNING: Version '$3' does not exist." >&2
      fi
      echo "$3" | tee "$NVM_ALIAS_DIR/$2" >/dev/null
      if [ ! "_$3" = "_$VERSION" ]; then
        echo "$2 -> $3 (-> $VERSION)"
      else
        echo "$2 -> $3"
      fi
    ;;
    "unalias" )
      local NVM_ALIAS_DIR
      NVM_ALIAS_DIR="$(nvm_alias_path)"
      command mkdir -p "$NVM_ALIAS_DIR"
      [ $# -ne 2 ] && nvm help && return 127
      [ ! -f "$NVM_ALIAS_DIR/$2" ] && echo "Alias $2 doesn't exist!" >&2 && return
      command rm -f "$NVM_ALIAS_DIR/$2"
      echo "Deleted alias $2"
    ;;
    "reinstall-packages" | "copy-packages" )
      if [ $# -ne 2 ]; then
        nvm help
        return 127
      fi

      local PROVIDED_VERSION
      PROVIDED_VERSION="$2"

      if [ "$PROVIDED_VERSION" = "$(nvm_ls_current)" ] || [ "$(nvm_version "$PROVIDED_VERSION")" = "$(nvm_ls_current)" ]; then
        echo 'Can not reinstall packages from the current version of node.' >&2
        return 2
      fi

      local INSTALLS
      if [ "_$PROVIDED_VERSION" = "_system" ]; then
        if ! nvm_has_system_node && ! nvm_has_system_iojs; then
          echo 'No system version of node or io.js detected.' >&2
          return 3
        fi
        INSTALLS=$(nvm deactivate > /dev/null && npm list -g --depth=0 | command tail -n +2 | command grep -o -e ' [^@]*' | command cut -c 2- | command grep -v npm | command xargs)
      else
        local VERSION
        VERSION="$(nvm_version "$PROVIDED_VERSION")"
        INSTALLS=$(nvm use "$VERSION" > /dev/null && npm list -g --depth=0 | command tail -n +2 | command grep -o -e ' [^@]*' | command cut -c 2- | command grep -v npm | command xargs)
      fi

      echo "Copying global packages from $VERSION..."
      echo "$INSTALLS" | command xargs npm install -g --quiet
    ;;
    "clear-cache" )
      command rm -f $NVM_DIR/v* "$(nvm_version_dir)" 2>/dev/null
      echo "Cache cleared."
    ;;
    "version" )
      nvm_version $2
    ;;
    "--version" )
      echo "0.23.3"
    ;;
    "unload" )
      unset -f nvm nvm_print_versions nvm_checksum \
        nvm_iojs_prefix nvm_node_prefix \
        nvm_add_iojs_prefix nvm_strip_iojs_prefix \
        nvm_is_iojs_version \
        nvm_ls_remote nvm_ls nvm_remote_version nvm_remote_versions \
        nvm_version nvm_rc_version \
        nvm_version_greater nvm_version_greater_than_or_equal_to \
        nvm_supports_source_options > /dev/null 2>&1
      unset RC_VERSION NVM_NODEJS_ORG_MIRROR NVM_DIR NVM_CD_FLAGS > /dev/null 2>&1
    ;;
    * )
      nvm help
    ;;
  esac
}

nvm_supports_source_options() {
  [ "_$(echo 'echo $1' | . /dev/stdin yes)" = "_yes" ]
}

if nvm_supports_source_options && [ "_$1" = "_--install" ]; then
  VERSION="$(nvm_alias default 2>/dev/null)"
  if [ -n "$VERSION" ]; then
    nvm install "$VERSION" >/dev/null
  elif nvm_rc_version >/dev/null 2>&1; then
    nvm install >/dev/null
  fi
elif nvm ls default >/dev/null; then
  nvm use default >/dev/null
elif nvm_rc_version >/dev/null 2>&1; then
  nvm use >/dev/null
fi

