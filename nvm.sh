# Node Version Manager
# Implemented as a POSIX-compliant function
# Should work on sh, dash, bash, ksh, zsh
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

{ # this ensures the entire script is downloaded #

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
    NVM_LATEST_URL="$(curl -q -w "%{url_effective}\n" -L -s -S http://latest.nvm.sh -o /dev/null)"
  elif nvm_has "wget"; then
    NVM_LATEST_URL="$(wget http://latest.nvm.sh --server-response -O /dev/null 2>&1 | command awk '/^  Location: /{DEST=$2} END{ print DEST }')"
  else
    >&2 echo 'nvm needs curl or wget to proceed.'
    return 1
  fi
  if [ "_$NVM_LATEST_URL" = "_" ]; then
    >&2 echo "http://latest.nvm.sh did not redirect to the latest release on Github"
    return 2
  else
    echo "$NVM_LATEST_URL" | command awk -F '/' '{print $NF}'
  fi
}

nvm_download() {
  if nvm_has "curl"; then
    curl -q $*
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

nvm_print_npm_version() {
  if nvm_has "npm"; then
    echo " (npm v$(npm --version 2>/dev/null))"
  fi
}

# Make zsh glob matching behave same as bash
# This fixes the "zsh: no matches found" errors
if [ -z "${NVM_CD_FLAGS-}" ]; then
  export NVM_CD_FLAGS=''
fi
if nvm_has "unsetopt"; then
  unsetopt nomatch 2>/dev/null
  NVM_CD_FLAGS="-q"
fi

# Auto detect the NVM_DIR when not set
if [ -z "${NVM_DIR-}" ]; then
  if [ -n "$BASH_SOURCE" ]; then
    NVM_SCRIPT_SOURCE="${BASH_SOURCE[0]}"
  fi
  NVM_DIR="$(cd $NVM_CD_FLAGS "$(dirname "${NVM_SCRIPT_SOURCE:-$0}")" > /dev/null && \pwd)"
  export NVM_DIR
fi
unset NVM_SCRIPT_SOURCE 2> /dev/null


# Setup mirror location if not already set
if [ -z "${NVM_NODEJS_ORG_MIRROR-}" ]; then
  export NVM_NODEJS_ORG_MIRROR="https://nodejs.org/dist"
fi

if [ -z "$NVM_IOJS_ORG_MIRROR" ]; then
  export NVM_IOJS_ORG_MIRROR="https://iojs.org/dist"
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
    read -r NVM_RC_VERSION < "$NVMRC_PATH"
    echo "Found '$NVMRC_PATH' with version <$NVM_RC_VERSION>"
  else
    >&2 echo "No .nvmrc file found"
    return 1
  fi
}

nvm_version_greater() {
  local LHS
  LHS="$(nvm_normalize_version "$1")"
  local RHS
  RHS="$(nvm_normalize_version "$2")"
  [ "$LHS" -gt "$RHS" ];
}

nvm_version_greater_than_or_equal_to() {
  local LHS
  LHS="$(nvm_normalize_version "$1")"
  local RHS
  RHS="$(nvm_normalize_version "$2")"
  [ "$LHS" -ge "$RHS" ];
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

nvm_ensure_version_installed() {
  local PROVIDED_VERSION
  PROVIDED_VERSION="$1"
  local LOCAL_VERSION
  local EXIT_CODE
  LOCAL_VERSION="$(nvm_version "$PROVIDED_VERSION")"
  EXIT_CODE="$?"
  local NVM_VERSION_DIR
  if [ "_$EXIT_CODE" = "_0" ]; then
    NVM_VERSION_DIR="$(nvm_version_path "$LOCAL_VERSION")"
  fi
  if [ "_$EXIT_CODE" != "_0" ] || [ ! -d "$NVM_VERSION_DIR" ]; then
    VERSION="$(nvm_resolve_alias "$PROVIDED_VERSION")"
    if [ $? -eq 0 ]; then
      echo "N/A: version \"$PROVIDED_VERSION -> $VERSION\" is not yet installed" >&2
    else
      local PREFIXED_VERSION
      PREFIXED_VERSION="$(nvm_ensure_version_prefix "$PROVIDED_VERSION")"
      echo "N/A: version \"${PREFIXED_VERSION:-$PROVIDED_VERSION}\" is not yet installed" >&2
    fi
    return 1
  fi
}

# Expand a version using the version cache
nvm_version() {
  local PATTERN
  PATTERN="$1"
  local VERSION
  # The default version is the current one
  if [ -z "$PATTERN" ]; then
    PATTERN='current'
  fi

  if [ "$PATTERN" = "current" ]; then
    nvm_ls_current
    return $?
  fi

  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"
  case "_$PATTERN" in
    "_$NVM_NODE_PREFIX" | "_$NVM_NODE_PREFIX-")
      PATTERN="stable"
    ;;
  esac
  VERSION="$(nvm_ls "$PATTERN" | command tail -n1)"
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
        VERSION="$(nvm_ls_remote_iojs | command tail -n1)"
      ;;
      *)
        VERSION="$(nvm_ls_remote "$PATTERN")"
      ;;
    esac
  else
    VERSION="$(nvm_remote_versions "$PATTERN" | command tail -n1)"
  fi
  echo "$VERSION"
  if [ "_$VERSION" = '_N/A' ]; then
    return 3
  fi
}

nvm_remote_versions() {
  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local PATTERN
  PATTERN="$1"
  case "_$PATTERN" in
    "_$NVM_IOJS_PREFIX" | "_io.js")
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
    "$(nvm_iojs_prefix)" | \
    "$(nvm_node_prefix)")
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
  echo "${1#v}" | command awk -F. '{ printf("%d%06d%06d\n", $1,$2,$3); }'
}

nvm_ensure_version_prefix() {
  local NVM_VERSION
  NVM_VERSION="$(nvm_strip_iojs_prefix "$1" | command sed -e 's/^\([0-9]\)/v\1/g')"
  if nvm_is_iojs_version "$1"; then
    nvm_add_iojs_prefix "$NVM_VERSION"
  else
    echo "$NVM_VERSION"
  fi
}

nvm_format_version() {
  local VERSION
  VERSION="$(nvm_ensure_version_prefix "$1")"
  local NUM_GROUPS
  NUM_GROUPS="$(nvm_num_version_groups "$VERSION")"
  if [ $NUM_GROUPS -lt 3 ]; then
    nvm_format_version "${VERSION%.}.0"
  else
    echo "$VERSION" | cut -f1-3 -d.
  fi
}

nvm_num_version_groups() {
  local VERSION
  VERSION="$1"
  VERSION="${VERSION#v}"
  VERSION="${VERSION%.}"
  if [ -z "$VERSION" ]; then
    echo "0"
    return
  fi
  local NVM_NUM_DOTS
  NVM_NUM_DOTS=$(echo "$VERSION" | command sed -e 's/[^\.]//g')
  local NVM_NUM_GROUPS
  NVM_NUM_GROUPS=".$NVM_NUM_DOTS" # add extra dot, since it's (n - 1) dots at this point
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
  nvm_version_greater_than_or_equal_to "$(nvm_strip_iojs_prefix "$1")" "$FIRST_VERSION_WITH_BINARY"
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

  command cat "$NVM_ALIAS_PATH"
}

nvm_ls_current() {
  local NVM_LS_CURRENT_NODE_PATH
  NVM_LS_CURRENT_NODE_PATH="$(command which node 2> /dev/null)"
  if [ $? -ne 0 ]; then
    echo 'none'
  elif nvm_tree_contains_path "$(nvm_version_dir iojs)" "$NVM_LS_CURRENT_NODE_PATH"; then
    nvm_add_iojs_prefix "$(iojs --version 2>/dev/null)"
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
      && command printf "$SEEN_ALIASES" | command grep -e "^$ALIAS_TEMP$" > /dev/null; then
      ALIAS="∞"
      break
    fi

    SEEN_ALIASES="$SEEN_ALIASES\n$ALIAS_TEMP"
    ALIAS="$ALIAS_TEMP"
  done

  if [ -n "$ALIAS" ] && [ "_$ALIAS" != "_$PATTERN" ]; then
    local NVM_IOJS_PREFIX
    NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
    local NVM_NODE_PREFIX
    NVM_NODE_PREFIX="$(nvm_node_prefix)"
    case "_$ALIAS" in
      "_∞" | \
      "_$NVM_IOJS_PREFIX" | "_$NVM_IOJS_PREFIX-" | \
      "_$NVM_NODE_PREFIX" )
        echo "$ALIAS"
      ;;
      *)
        nvm_ensure_version_prefix "$ALIAS"
      ;;
    esac
    return 0
  fi

  if nvm_validate_implicit_alias "$PATTERN" 2> /dev/null ; then
    local IMPLICIT
    IMPLICIT="$(nvm_print_implicit_alias local "$PATTERN" 2> /dev/null)"
    if [ -n "$IMPLICIT" ]; then
      nvm_ensure_version_prefix "$IMPLICIT"
    fi
  fi

  return 2
}

nvm_resolve_local_alias() {
  if [ -z "$1" ]; then
    return 1
  fi

  local VERSION
  local EXIT_CODE
  VERSION="$(nvm_resolve_alias "$1")"
  EXIT_CODE=$?
  if [ -z "$VERSION" ]; then
    return $EXIT_CODE
  fi
  if [ "_$VERSION" != "_∞" ]; then
    nvm_version "$VERSION"
  else
    echo "$VERSION"
  fi
}

nvm_iojs_prefix() {
  echo "iojs"
}
nvm_node_prefix() {
  echo "node"
}

nvm_is_iojs_version() {
  case "$1" in iojs-*) return 0 ;; esac
  return 1
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
    echo "${1#"$NVM_IOJS_PREFIX"-}"
  fi
}

nvm_ls() {
  local PATTERN
  PATTERN="${1-}"
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
  NVM_VERSION_DIR_IOJS="$(nvm_version_dir "$NVM_IOJS_PREFIX")"
  local NVM_VERSION_DIR_NEW
  NVM_VERSION_DIR_NEW="$(nvm_version_dir new)"
  local NVM_VERSION_DIR_OLD
  NVM_VERSION_DIR_OLD="$(nvm_version_dir old)"

  case "$PATTERN" in
    "$NVM_IOJS_PREFIX" | "$NVM_NODE_PREFIX" )
      PATTERN="$PATTERN-"
    ;;
    *)
      if nvm_resolve_local_alias "$PATTERN"; then
        return
      fi
      PATTERN="$(nvm_ensure_version_prefix "$PATTERN")"
    ;;
  esac
  if [ "_$PATTERN" = "_N/A" ]; then
    return
  fi
  # If it looks like an explicit version, don't do anything funny
  local NVM_PATTERN_STARTS_WITH_V
  case $PATTERN in
    v*) NVM_PATTERN_STARTS_WITH_V=true ;;
    *) NVM_PATTERN_STARTS_WITH_V=false ;;
  esac
  if [ $NVM_PATTERN_STARTS_WITH_V = true ] && [ "_$(nvm_num_version_groups "$PATTERN")" = "_3" ]; then
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
          PATTERN="${PATTERN%.}."
        fi
      ;;
    esac

    local ZHS_HAS_SHWORDSPLIT_UNSET
    ZHS_HAS_SHWORDSPLIT_UNSET=1
    if nvm_has "setopt"; then
      ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
      setopt shwordsplit
    fi

    local NVM_DIRS_TO_SEARCH1
    NVM_DIRS_TO_SEARCH1=''
    local NVM_DIRS_TO_SEARCH2
    NVM_DIRS_TO_SEARCH2=''
    local NVM_DIRS_TO_SEARCH3
    NVM_DIRS_TO_SEARCH3=''
    local NVM_ADD_SYSTEM
    NVM_ADD_SYSTEM=false
    if nvm_is_iojs_version "$PATTERN"; then
      NVM_DIRS_TO_SEARCH1="$NVM_VERSION_DIR_IOJS"
      PATTERN="$(nvm_strip_iojs_prefix "$PATTERN")"
      if nvm_has_system_iojs; then
        NVM_ADD_SYSTEM=true
      fi
    elif [ "_$PATTERN" = "_$NVM_NODE_PREFIX-" ]; then
      NVM_DIRS_TO_SEARCH1="$NVM_VERSION_DIR_OLD"
      NVM_DIRS_TO_SEARCH2="$NVM_VERSION_DIR_NEW"
      PATTERN=''
      if nvm_has_system_node; then
        NVM_ADD_SYSTEM=true
      fi
    else
      NVM_DIRS_TO_SEARCH1="$NVM_VERSION_DIR_OLD"
      NVM_DIRS_TO_SEARCH2="$NVM_VERSION_DIR_NEW"
      NVM_DIRS_TO_SEARCH3="$NVM_VERSION_DIR_IOJS"
      if nvm_has_system_iojs || nvm_has_system_node; then
        NVM_ADD_SYSTEM=true
      fi
    fi

    if ! [ -d "$NVM_DIRS_TO_SEARCH1" ]; then
      NVM_DIRS_TO_SEARCH1=''
    fi
    if ! [ -d "$NVM_DIRS_TO_SEARCH2" ]; then
      NVM_DIRS_TO_SEARCH2="$NVM_DIRS_TO_SEARCH1"
    fi
    if ! [ -d "$NVM_DIRS_TO_SEARCH3" ]; then
      NVM_DIRS_TO_SEARCH3="$NVM_DIRS_TO_SEARCH2"
    fi

    if [ -z "$PATTERN" ]; then
      PATTERN='v'
    fi
    if [ -n "$NVM_DIRS_TO_SEARCH1$NVM_DIRS_TO_SEARCH2$NVM_DIRS_TO_SEARCH3" ]; then
      VERSIONS="$(command find "$NVM_DIRS_TO_SEARCH1" "$NVM_DIRS_TO_SEARCH2" "$NVM_DIRS_TO_SEARCH3" -maxdepth 1 -type d -name "$PATTERN*" \
        | command sed "
            s#$NVM_VERSION_DIR_IOJS/#$NVM_IOJS_PREFIX-#;
            \#$NVM_VERSION_DIR_IOJS# d;
            s#^$NVM_DIR/##;
            \#^versions\$# d;
            s#^versions/##;
            s#^v#$NVM_NODE_PREFIX-v#;
            s#^\($NVM_IOJS_PREFIX\)[-/]v#\1.v#;
            s#^\($NVM_NODE_PREFIX\)[-/]v#\1.v#" \
        | command sort -t. -u -k 2.2,2n -k 3,3n -k 4,4n \
        | command sed "
            s/^\($NVM_IOJS_PREFIX\)\./\1-/;
            s/^$NVM_NODE_PREFIX\.//" \
      )"
    fi

    if [ "$ZHS_HAS_SHWORDSPLIT_UNSET" -eq 1 ] && nvm_has "unsetopt"; then
      unsetopt shwordsplit
    fi
  fi

  if [ "${NVM_ADD_SYSTEM-}" = true ]; then
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
  if nvm_validate_implicit_alias "$PATTERN" 2> /dev/null ; then
    PATTERN="$(nvm_ls_remote "$(nvm_print_implicit_alias remote "$PATTERN")" | command tail -n1)"
  elif [ -n "$PATTERN" ]; then
    PATTERN="$(nvm_ensure_version_prefix "$PATTERN")"
  else
    PATTERN=".*"
  fi
  nvm_ls_remote_index_tab node std "$NVM_NODEJS_ORG_MIRROR" "$PATTERN"
}

nvm_ls_remote_iojs() {
  nvm_ls_remote_index_tab iojs std "$NVM_IOJS_ORG_MIRROR" "$1"
}

nvm_ls_remote_index_tab() {
  if [ "$#" -lt 4 ]; then
    echo "not enough arguments" >&2
    return 5
  fi
  local TYPE
  TYPE="$1"
  local PREFIX
  PREFIX=''
  case "$TYPE-$2" in
    iojs-std) PREFIX="$(nvm_iojs_prefix)-" ;;
    node-std) PREFIX='' ;;
    iojs-*)
      echo "unknown type of io.js release" >&2
      return 4
    ;;
    node-*)
      echo "unknown type of node.js release" >&2
      return 4
    ;;
  esac
  local SORT_COMMAND
  SORT_COMMAND='sort'
  case "$TYPE" in
    node) SORT_COMMAND='sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n' ;;
  esac
  local MIRROR
  MIRROR="$3"
  local PATTERN
  PATTERN="$4"
  local VERSIONS
  if [ -n "$PATTERN" ]; then
    if [ "_$TYPE" = "_iojs" ]; then
      PATTERN="$(nvm_ensure_version_prefix "$(nvm_strip_iojs_prefix "$PATTERN")")"
    else
      PATTERN="$(nvm_ensure_version_prefix "$PATTERN")"
    fi
  else
    PATTERN=".*"
  fi
  ZHS_HAS_SHWORDSPLIT_UNSET=1
  if nvm_has "setopt"; then
    ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
    setopt shwordsplit
  fi
  VERSIONS="$(nvm_download -L -s "$MIRROR/index.tab" -o - \
    | command sed "
        1d;
        s/^/$PREFIX/;
        s/[[:blank:]].*//" \
    | command grep -w "$PATTERN" \
    | $SORT_COMMAND)"
  if [ "$ZHS_HAS_SHWORDSPLIT_UNSET" -eq 1 ] && nvm_has "unsetopt"; then
    unsetopt shwordsplit
  fi
  if [ -z "$VERSIONS" ]; then
    echo "N/A"
    return 3
  fi
  echo "$VERSIONS"
}

nvm_checksum() {
  local NVM_CHECKSUM
  if [ -z "$3" ] || [ "$3" == "sha1" ]; then
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
  else
    if nvm_has "sha256sum" && ! nvm_is_alias "sha256sum"; then
      NVM_CHECKSUM="$(sha256sum "$1" | awk '{print $1}')"
    elif nvm_has "shasum" && ! nvm_is_alias "shasum"; then
      NVM_CHECKSUM="$(shasum -a 256 "$1" | awk '{print $1}')"
    elif nvm_has "sha256" && ! nvm_is_alias "sha256"; then
      NVM_CHECKSUM="$(sha256 -q "$1" | awk '{print $1}')"
    elif nvm_has "gsha256sum" && ! nvm_is_alias "gsha256sum"; then
      NVM_CHECKSUM="$(gsha256sum "$1" | awk '{print $1}')"
    elif nvm_has "openssl" && ! nvm_is_alias "openssl"; then
      NVM_CHECKSUM="$(openssl dgst -sha256 "$1" | rev | awk '{print $1}' | rev)"
    elif nvm_has "libressl" && ! nvm_is_alias "libressl"; then
      NVM_CHECKSUM="$(libressl dgst -sha256 "$1" | rev | awk '{print $1}' | rev)"
    elif nvm_has "bssl" && ! nvm_is_alias "bssl"; then
      NVM_CHECKSUM="$(bssl sha256sum "$1" | awk '{print $1}')"
    else
      echo "Unaliased sha256sum, shasum, sha256, gsha256sum, openssl, libressl, or bssl not found." >&2
      echo "WARNING: Continuing *without checksum verification*" >&2
      return
    fi
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
  echo "$1" | while read -r VERSION; do
    if [ "_$VERSION" = "_$NVM_CURRENT" ]; then
      FORMAT='\033[0;32m-> %12s\033[0m'
    elif [ "$VERSION" = "system" ]; then
      FORMAT='\033[0;33m%15s\033[0m'
    elif [ -d "$(nvm_version_path "$VERSION" 2> /dev/null)" ]; then
      FORMAT='\033[0;34m%15s\033[0m'
    else
      FORMAT='%15s'
    fi
    command printf "$FORMAT\n" "$VERSION"
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

  local NVM_IMPLICIT
  NVM_IMPLICIT="$2"
  if ! nvm_validate_implicit_alias "$NVM_IMPLICIT"; then
    return 2
  fi

  local ZHS_HAS_SHWORDSPLIT_UNSET

  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local NVM_NODE_PREFIX
  NVM_NODE_PREFIX="$(nvm_node_prefix)"
  local NVM_COMMAND
  local NVM_ADD_PREFIX_COMMAND
  local LAST_TWO
  case "$NVM_IMPLICIT" in
    "$NVM_IOJS_PREFIX")
      NVM_COMMAND="nvm_ls_remote_iojs"
      NVM_ADD_PREFIX_COMMAND="nvm_add_iojs_prefix"
      if [ "_$1" = "_local" ]; then
        NVM_COMMAND="nvm_ls $NVM_IMPLICIT"
      fi

      ZHS_HAS_SHWORDSPLIT_UNSET=1
      if nvm_has "setopt"; then
        ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
        setopt shwordsplit
      fi

      local NVM_IOJS_VERSION
      local EXIT_CODE
      NVM_IOJS_VERSION="$($NVM_COMMAND)"
      EXIT_CODE="$?"
      if [ "_$EXIT_CODE" = "_0" ]; then
        NVM_IOJS_VERSION="$(echo "$NVM_IOJS_VERSION" | sed "s/^$NVM_IMPLICIT-//" | command grep -e '^v' | command cut -c2- | command cut -d . -f 1,2 | uniq | command tail -1)"
      fi

      if [ "$ZHS_HAS_SHWORDSPLIT_UNSET" -eq 1 ] && nvm_has "unsetopt"; then
        unsetopt shwordsplit
      fi

      if [ "_$NVM_IOJS_VERSION" = "_N/A" ]; then
        echo "N/A"
      else
        $NVM_ADD_PREFIX_COMMAND "$NVM_IOJS_VERSION"
      fi
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

      LAST_TWO=$($NVM_COMMAND | command grep -e '^v' | command cut -c2- | command cut -d . -f 1,2 | uniq)

      if [ "$ZHS_HAS_SHWORDSPLIT_UNSET" -eq 1 ] && nvm_has "unsetopt"; then
        unsetopt shwordsplit
      fi
    ;;
  esac
  local MINOR
  local STABLE
  local UNSTABLE
  local MOD
  local NORMALIZED_VERSION

  ZHS_HAS_SHWORDSPLIT_UNSET=1
  if nvm_has "setopt"; then
    ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
    setopt shwordsplit
  fi
  for MINOR in $LAST_TWO; do
    NORMALIZED_VERSION="$(nvm_normalize_version "$MINOR")"
    if [ "_0${NORMALIZED_VERSION#?}" != "_$NORMALIZED_VERSION" ]; then
      STABLE="$MINOR"
    else
      MOD=$(expr "$NORMALIZED_VERSION" \/ 1000000 \% 2)
      if [ "$MOD" -eq 0 ]; then
        STABLE="$MINOR"
      elif [ "$MOD" -eq 1 ]; then
        UNSTABLE="$MINOR"
      fi
    fi
  done
  if [ "$ZHS_HAS_SHWORDSPLIT_UNSET" -eq 1 ] && nvm_has "unsetopt"; then
    unsetopt shwordsplit
  fi

  if [ "_$2" = '_stable' ]; then
    echo "${STABLE}"
  elif [ "_$2" = '_unstable' ]; then
    echo "${UNSTABLE}"
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
  local HOST_ARCH
  local NVM_OS
  local EXIT_CODE

  NVM_OS="$(nvm_get_os)"
  # If the OS is SunOS, first try to use pkgsrc to guess
  # the most appropriate arch. If it's not available, use
  # isainfo to get the instruction set supported by the
  # kernel.
  if [ "_$NVM_OS" = "_sunos" ]; then
    HOST_ARCH=$(pkg_info -Q MACHINE_ARCH pkg_install)
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      HOST_ARCH=$(isainfo -n)
    fi
  else
     HOST_ARCH="$(uname -m)"
  fi

  local NVM_ARCH
  case "$HOST_ARCH" in
    x86_64 | amd64) NVM_ARCH="x64" ;;
    i*86) NVM_ARCH="x86" ;;
    *) NVM_ARCH="$HOST_ARCH" ;;
  esac
  echo "$NVM_ARCH"
}

nvm_get_minor_version() {
  local VERSION
  VERSION="$1"

  if [ -z "$VERSION" ]; then
    echo 'a version is required' >&2
    return 1
  fi

  case "$VERSION" in
    v | .* | *..* | v*[!.0123456789]* | [!v]*[!.0123456789]* | [!v0123456789]* | v[!0123456789]*)
      echo 'invalid version number' >&2
      return 2
    ;;
  esac

  local PREFIXED_VERSION
  PREFIXED_VERSION="$(nvm_format_version "$VERSION")"

  local MINOR
  MINOR="$(echo "$PREFIXED_VERSION" | command grep -e '^v' | command cut -c2- | command cut -d . -f 1,2)"
  if [ -z "$MINOR" ]; then
    echo 'invalid version number! (please report this)' >&2
    return 3
  fi
  echo "$MINOR"
}

nvm_ensure_default_set() {
  local VERSION
  VERSION="$1"
  if [ -z "$VERSION" ]; then
    echo 'nvm_ensure_default_set: a version is required' >&2
    return 1
  fi
  if nvm_alias default >/dev/null 2>&1; then
    # default already set
    return 0
  fi
  local OUTPUT
  OUTPUT="$(nvm alias default "$VERSION")"
  local EXIT_CODE
  EXIT_CODE="$?"
  echo "Creating default alias: $OUTPUT"
  return $EXIT_CODE
}

nvm_is_merged_node_version() {
   nvm_version_greater_than_or_equal_to "$1" v4.0.0
}

nvm_install_merged_node_binary() {
  local NVM_NODE_TYPE
  NVM_NODE_TYPE="$1"
  local MIRROR
  if [ "_$NVM_NODE_TYPE" = "_std" ]; then
    MIRROR="$NVM_NODEJS_ORG_MIRROR"
  else
    echo "unknown type of node.js release" >&2
    return 4
  fi
  local VERSION
  VERSION="$2"
  local REINSTALL_PACKAGES_FROM
  REINSTALL_PACKAGES_FROM="$3"

  if ! nvm_is_merged_node_version "$VERSION" || nvm_is_iojs_version "$VERSION"; then
    echo 'nvm_install_merged_node_binary requires a node version v4.0 or greater.' >&2
    return 10
  fi

  local VERSION_PATH
  VERSION_PATH="$(nvm_version_path "$VERSION")"
  local NVM_OS
  NVM_OS="$(nvm_get_os)"
  local t
  local url
  local sum
  local NODE_PREFIX
  local compression
  compression="gz"
  local tar_compression_flag
  tar_compression_flag="x"
  if nvm_supports_xz "$VERSION"; then
    compression="xz"
    tar_compression_flag="J"
  fi
  NODE_PREFIX="$(nvm_node_prefix)"

  if [ -n "$NVM_OS" ]; then
    t="$VERSION-$NVM_OS-$(nvm_get_arch)"
    url="$MIRROR/$VERSION/$NODE_PREFIX-${t}.tar.${compression}"
    sum="$(nvm_download -L -s "$MIRROR/$VERSION/SHASUMS256.txt" -o - | command grep "${NODE_PREFIX}-${t}.tar.${compression}" | command awk '{print $1}')"
    local tmpdir
    tmpdir="$NVM_DIR/bin/node-${t}"
    local tmptarball
    tmptarball="$tmpdir/node-${t}.tar.${compression}"
    local NVM_INSTALL_ERRORED
    command mkdir -p "$tmpdir" && \
      echo "Downloading $url..." && \
      nvm_download -L -C - --progress-bar "$url" -o "$tmptarball" || \
      NVM_INSTALL_ERRORED=true
    if grep '404 Not Found' "$tmptarball" >/dev/null; then
      NVM_INSTALL_ERRORED=true
      echo >&2 "HTTP 404 at URL $url";
    fi
    if (
      [ "$NVM_INSTALL_ERRORED" != true ] && \
      nvm_checksum "$tmptarball" "$sum" "sha256" && \
      command tar -x${tar_compression_flag}f "$tmptarball" -C "$tmpdir" --strip-components 1 && \
      command rm -f "$tmptarball" && \
      command mkdir -p "$VERSION_PATH" && \
      command mv "$tmpdir"/* "$VERSION_PATH"
    ); then
      return 0
    else
      echo >&2 "Binary download failed, trying source." >&2
      command rm -rf "$tmptarball" "$tmpdir"
      return 1
    fi
  fi
  return 2
}

nvm_install_iojs_binary() {
  local NVM_IOJS_TYPE
  NVM_IOJS_TYPE="$1"
  local MIRROR
  if [ "_$NVM_IOJS_TYPE" = "_std" ]; then
    MIRROR="$NVM_IOJS_ORG_MIRROR"
  else
    echo "unknown type of io.js release" >&2
    return 4
  fi
  local PREFIXED_VERSION
  PREFIXED_VERSION="$2"
  local REINSTALL_PACKAGES_FROM
  REINSTALL_PACKAGES_FROM="$3"

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
  local compression
  compression="gz"
  local tar_compression_flag
  tar_compression_flag="x"
  if nvm_supports_xz "$VERSION"; then
    compression="xz"
    tar_compression_flag="J"
  fi

  if [ -n "$NVM_OS" ]; then
    if nvm_binary_available "$VERSION"; then
      t="$VERSION-$NVM_OS-$(nvm_get_arch)"
      url="$MIRROR/$VERSION/$(nvm_iojs_prefix)-${t}.tar.${compression}"
      sum="$(nvm_download -L -s "$MIRROR/$VERSION/SHASUMS256.txt" -o - | command grep "$(nvm_iojs_prefix)-${t}.tar.${compression}" | command awk '{print $1}')"
      local tmpdir
      tmpdir="$NVM_DIR/bin/iojs-${t}"
      local tmptarball
      tmptarball="$tmpdir/iojs-${t}.tar.${compression}"
      local NVM_INSTALL_ERRORED
      command mkdir -p "$tmpdir" && \
        echo "Downloading $url..." && \
        nvm_download -L -C - --progress-bar "$url" -o "$tmptarball" || \
        NVM_INSTALL_ERRORED=true
      if grep '404 Not Found' "$tmptarball" >/dev/null; then
        NVM_INSTALL_ERRORED=true
        echo >&2 "HTTP 404 at URL $url";
      fi
      if (
        [ "$NVM_INSTALL_ERRORED" != true ] && \
        nvm_checksum "$tmptarball" "$sum" "sha256" && \
        command tar -x${tar_compression_flag}f "$tmptarball" -C "$tmpdir" --strip-components 1 && \
        command rm -f "$tmptarball" && \
        command mkdir -p "$VERSION_PATH" && \
        command mv "$tmpdir"/* "$VERSION_PATH"
      ); then
        return 0
      else
        echo >&2 "Binary download failed, trying source." >&2
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

  if nvm_is_iojs_version "$VERSION"; then
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
      local NVM_ARCH
      NVM_ARCH="$(nvm_get_arch)"
      if [ "_$NVM_ARCH" = '_armv6l' ] || [ "_$NVM_ARCH" = 'armv7l' ]; then
         NVM_ARCH="arm-pi"
      fi
      t="$VERSION-$NVM_OS-$NVM_ARCH"
      url="$NVM_NODEJS_ORG_MIRROR/$VERSION/node-${t}.tar.gz"
      sum=$(nvm_download -L -s "$NVM_NODEJS_ORG_MIRROR/$VERSION/SHASUMS.txt" -o - | command grep "node-${t}.tar.gz" | command awk '{print $1}')
      local tmpdir
      tmpdir="$NVM_DIR/bin/node-${t}"
      local tmptarball
      tmptarball="$tmpdir/node-${t}.tar.gz"
      local NVM_INSTALL_ERRORED
      command mkdir -p "$tmpdir" && \
        nvm_download -L -C - --progress-bar "$url" -o "$tmptarball" || \
        NVM_INSTALL_ERRORED=true
      if grep '404 Not Found' "$tmptarball" >/dev/null; then
        NVM_INSTALL_ERRORED=true
        echo >&2 "HTTP 404 at URL $url";
      fi
      if (
        [ "$NVM_INSTALL_ERRORED" != true ] && \
        nvm_checksum "$tmptarball" "$sum" && \
        command tar -xzf "$tmptarball" -C "$tmpdir" --strip-components 1 && \
        command rm -f "$tmptarball" && \
        command mkdir -p "$VERSION_PATH" && \
        command mv "$tmpdir"/* "$VERSION_PATH"
      ); then
        return 0
      else
        echo >&2 "Binary download failed, trying source."
        command rm -rf "$tmptarball" "$tmpdir"
        return 1
      fi
    fi
  fi
  return 2
}

nvm_get_make_jobs() {
  if nvm_is_natural_num "${1-}"; then
    NVM_MAKE_JOBS="$1"
    echo "number of \`make\` jobs: $NVM_MAKE_JOBS"
    return
  elif [ -n "${1-}" ]; then
    unset NVM_MAKE_JOBS
    echo >&2 "$1 is invalid for number of \`make\` jobs, must be a natural number"
  fi
  local NVM_OS
  NVM_OS="$(nvm_get_os)"
  local NVM_CPU_THREADS
  if [ "_$NVM_OS" = "_linux" ]; then
    NVM_CPU_THREADS="$(grep -c 'core id' /proc/cpuinfo)"
  elif [ "_$NVM_OS" = "_freebsd" ] || [ "_$NVM_OS" = "_darwin" ]; then
    NVM_CPU_THREADS="$(sysctl -n hw.ncpu)"
  elif [ "_$NVM_OS" = "_sunos" ]; then
    NVM_CPU_THREADS="$(psrinfo | wc -l)"
  fi
  if ! nvm_is_natural_num "$NVM_CPU_THREADS" ; then
    echo "Can not determine how many thread(s) we can use, set to only 1 now." >&2
    echo "Please report an issue on GitHub to help us make it better and run it faster on your computer!" >&2
    NVM_MAKE_JOBS=1
  else
    echo "Detected that you have $NVM_CPU_THREADS CPU thread(s)"
    if [ $NVM_CPU_THREADS -gt 2 ]; then
      NVM_MAKE_JOBS=$(($NVM_CPU_THREADS - 1))
      echo "Set the number of jobs to $NVM_CPU_THREADS - 1 = $NVM_MAKE_JOBS jobs to speed up the build"
    else
      NVM_MAKE_JOBS=1
      echo "Number of CPU thread(s) less or equal to 2 will have only one job a time for 'make'"
    fi
  fi
}

nvm_install_node_source() {
  local VERSION
  VERSION="$1"
  local NVM_MAKE_JOBS
  NVM_MAKE_JOBS="$2"
  local ADDITIONAL_PARAMETERS
  ADDITIONAL_PARAMETERS="$3"

  local NVM_ARCH
  NVM_ARCH="$(nvm_get_arch)"
  if [ "_$NVM_ARCH" = '_armv6l' ] || [ "_$NVM_ARCH" = '_armv7l' ]; then
    ADDITIONAL_PARAMETERS="--without-snapshot $ADDITIONAL_PARAMETERS"
  fi

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

  if [ "$(nvm_download -L -s -I "$NVM_NODEJS_ORG_MIRROR/$VERSION/node-$VERSION.tar.gz" -o - 2>&1 | command grep '200 OK')" != '' ]; then
    tarball="$NVM_NODEJS_ORG_MIRROR/$VERSION/node-$VERSION.tar.gz"
    sum=$(nvm_download -L -s "$NVM_NODEJS_ORG_MIRROR/$VERSION/SHASUMS.txt" -o - | command grep "node-${VERSION}.tar.gz" | command awk '{print $1}')
  elif [ "$(nvm_download -L -s -I "$NVM_NODEJS_ORG_MIRROR/node-$VERSION.tar.gz" -o - | command grep '200 OK')" != '' ]; then
    tarball="$NVM_NODEJS_ORG_MIRROR/node-$VERSION.tar.gz"
  fi

  if (
    [ -n "$tarball" ] && \
    command mkdir -p "$tmpdir" && \
    echo "Downloading $tarball..." && \
    nvm_download -L --progress-bar "$tarball" -o "$tmptarball" && \
    nvm_checksum "$tmptarball" "$sum" && \
    command tar -xzf "$tmptarball" -C "$tmpdir" && \
    cd "$tmpdir/node-$VERSION" && \
    ./configure --prefix="$VERSION_PATH" $ADDITIONAL_PARAMETERS && \
    $make -j $NVM_MAKE_JOBS ${MAKE_CXX-} && \
    command rm -f "$VERSION_PATH" 2>/dev/null && \
    $make -j $NVM_MAKE_JOBS ${MAKE_CXX-} install
    )
  then
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

nvm_match_version() {
  local NVM_IOJS_PREFIX
  NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
  local PROVIDED_VERSION
  PROVIDED_VERSION="$1"
  case "_$PROVIDED_VERSION" in
    "_$NVM_IOJS_PREFIX" | "_io.js")
      nvm_version "$NVM_IOJS_PREFIX"
    ;;
    "_system")
      echo "system"
    ;;
    *)
      nvm_version "$PROVIDED_VERSION"
    ;;
  esac
}

nvm_npm_global_modules() {
  local NPMLIST
  local VERSION
  VERSION="$1"
  if [ "_$VERSION" = "_system" ]; then
    NPMLIST=$(nvm use system > /dev/null && npm list -g --depth=0 2> /dev/null | command tail -n +2)
  else
    NPMLIST=$(nvm use "$VERSION" > /dev/null && npm list -g --depth=0 2> /dev/null | command tail -n +2)
  fi

  local INSTALLS
  INSTALLS=$(echo "$NPMLIST" | command sed -e '/ -> / d' -e '/\(empty\)/ d' -e 's/^.* \(.*@[^ ]*\).*/\1/' -e '/^npm@[^ ]*.*$/ d' | command xargs)

  local LINKS
  LINKS="$(echo "$NPMLIST" | command sed -n 's/.* -> \(.*\)/\1/ p')"

  echo "$INSTALLS //// $LINKS"
}

nvm_die_on_prefix() {
  local NVM_DELETE_PREFIX
  NVM_DELETE_PREFIX="$1"
  case "$NVM_DELETE_PREFIX" in
    0|1) ;;
    *)
      echo >&2 'First argument "delete the prefix" must be zero or one'
      return 1
    ;;
  esac
  local NVM_COMMAND
  NVM_COMMAND="$2"
  if [ -z "$NVM_COMMAND" ]; then
    echo >&2 'Second argument "nvm command" must be nonempty'
    return 2
  fi

  if [ -n "${PREFIX-}" ] && ! (nvm_tree_contains_path "$NVM_DIR" "$PREFIX" >/dev/null 2>&1); then
    nvm deactivate >/dev/null 2>&1
    echo >&2 "nvm is not compatible with the \"PREFIX\" environment variable: currently set to \"$PREFIX\""
    echo >&2 "Run \`unset PREFIX\` to unset it."
    return 3
  fi

  if [ -n "${NPM_CONFIG_PREFIX-}" ] && ! (nvm_tree_contains_path "$NVM_DIR" "$NPM_CONFIG_PREFIX" >/dev/null 2>&1); then
    nvm deactivate >/dev/null 2>&1
    echo >&2 "nvm is not compatible with the \"NPM_CONFIG_PREFIX\" environment variable: currently set to \"$NPM_CONFIG_PREFIX\""
    echo >&2 "Run \`unset NPM_CONFIG_PREFIX\` to unset it."
    return 4
  fi

  if ! nvm_has 'npm'; then
    return
  fi

  local NVM_NPM_PREFIX
  NVM_NPM_PREFIX="$(NPM_CONFIG_LOGLEVEL=warn npm config get prefix)"
  if ! (nvm_tree_contains_path "$NVM_DIR" "$NVM_NPM_PREFIX" >/dev/null 2>&1); then
    if [ "_$NVM_DELETE_PREFIX" = "_1" ]; then
      NPM_CONFIG_LOGLEVEL=warn npm config delete prefix
    else
      nvm deactivate >/dev/null 2>&1
      echo >&2 "nvm is not compatible with the npm config \"prefix\" option: currently set to \"$NVM_NPM_PREFIX\""
      if nvm_has 'npm'; then
        echo >&2 "Run \`npm config delete prefix\` or \`$NVM_COMMAND\` to unset it."
      else
        echo >&2 "Run \`$NVM_COMMAND\` to unset it."
      fi
      return 10
    fi
  fi
}

# Succeeds if $IOJS_VERSION represents an io.js version that has a
# Solaris binary, fails otherwise.
# Currently, only io.js 3.3.1 has a Solaris binary available, and it's the
# latest io.js version available. The expectation is that any potential io.js
# version later than v3.3.1 will also have Solaris binaries.
iojs_version_has_solaris_binary() {
  local IOJS_VERSION
  IOJS_VERSION="$1"
  local STRIPPED_IOJS_VERSION
  STRIPPED_IOJS_VERSION="$(nvm_strip_iojs_prefix "$IOJS_VERSION")"
  if [ "_$STRIPPED_IOJS_VERSION" = "$IOJS_VERSION" ]; then
    return 1
  fi

  # io.js started shipping Solaris binaries with io.js v3.3.1
  nvm_version_greater_than_or_equal_to "$STRIPPED_IOJS_VERSION" v3.3.1
}

# Succeeds if $NODE_VERSION represents a node version that has a
# Solaris binary, fails otherwise.
# Currently, node versions starting from v0.8.6 have a Solaris binary
# avaliable.
node_version_has_solaris_binary() {
  local NODE_VERSION
  NODE_VERSION="$1"
  # Error out if $NODE_VERSION is actually an io.js version
  local STRIPPED_IOJS_VERSION
  STRIPPED_IOJS_VERSION="$(nvm_strip_iojs_prefix "$NODE_VERSION")"
  if [ "_$STRIPPED_IOJS_VERSION" != "_$NODE_VERSION" ]; then
    return 1
  fi

  # node (unmerged) started shipping Solaris binaries with v0.8.6 and
  # node versions v1.0.0 or greater are not considered valid "unmerged" node
  # versions.
  nvm_version_greater_than_or_equal_to "$NODE_VERSION" v0.8.6 &&
  ! nvm_version_greater_than_or_equal_to "$NODE_VERSION" v1.0.0
}

# Succeeds if $VERSION represents a version (node, io.js or merged) that has a
# Solaris binary, fails otherwise.
nvm_has_solaris_binary() {
  local VERSION=$1
  if nvm_is_merged_node_version "$VERSION"; then
    return 0 # All merged node versions have a Solaris binary
  elif nvm_is_iojs_version "$VERSION"; then
    iojs_version_has_solaris_binary "$VERSION"
  else
    node_version_has_solaris_binary "$VERSION"
  fi
}

nvm_sanitize_path() {
  local SANITIZED_PATH
  SANITIZED_PATH="$1"
  if [ "_$1" != "_$NVM_DIR" ]; then
    SANITIZED_PATH="$(echo "$SANITIZED_PATH" | command sed "s#$NVM_DIR#\$NVM_DIR#g")"
  fi
  echo "$SANITIZED_PATH" | command sed "s#$HOME#\$HOME#g"
}

nvm_is_natural_num() {
  if [ -z "$1" ]; then
    return 4
  fi
  case "$1" in
    0) return 1 ;;
    -*) return 3 ;; # some BSDs return false positives for double-negated args
    *)
      [ $1 -eq $1 2> /dev/null ] # returns 2 if it doesn't match
    ;;
  esac
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
      local NVM_IOJS_PREFIX
      NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
      local NVM_NODE_PREFIX
      NVM_NODE_PREFIX="$(nvm_node_prefix)"
      echo
      echo "Node Version Manager"
      echo
      echo 'Note: <version> refers to any version-like string nvm understands. This includes:'
      echo '  - full or partial version numbers, starting with an optional "v" (0.10, v0.1.2, v1)'
      echo "  - default (built-in) aliases: $NVM_NODE_PREFIX, stable, unstable, $NVM_IOJS_PREFIX, system"
      echo '  - custom aliases you define with `nvm alias foo`'
      echo
      echo 'Usage:'
      echo '  nvm help                                  Show this message'
      echo '  nvm --version                             Print out the latest released version of nvm'
      echo '  nvm install [-s] <version>                Download and install a <version>, [-s] from source. Uses .nvmrc if available'
      echo '    --reinstall-packages-from=<version>     When installing, reinstall packages installed in <node|iojs|node version number>'
      echo '  nvm uninstall <version>                   Uninstall a version'
      echo '  nvm use [--silent] <version>              Modify PATH to use <version>. Uses .nvmrc if available'
      echo '  nvm exec [--silent] <version> [<command>] Run <command> on <version>. Uses .nvmrc if available'
      echo '  nvm run [--silent] <version> [<args>]     Run `node` on <version> with <args> as arguments. Uses .nvmrc if available'
      echo '  nvm current                               Display currently activated version'
      echo '  nvm ls                                    List installed versions'
      echo '  nvm ls <version>                          List versions matching a given description'
      echo '  nvm ls-remote                             List remote versions available for install'
      echo '  nvm version <version>                     Resolve the given description to a single local version'
      echo '  nvm version-remote <version>              Resolve the given description to a single remote version'
      echo '  nvm deactivate                            Undo effects of `nvm` on current shell'
      echo '  nvm alias [<pattern>]                     Show all aliases beginning with <pattern>'
      echo '  nvm alias <name> <version>                Set an alias named <name> pointing to <version>'
      echo '  nvm unalias <name>                        Deletes the alias named <name>'
      echo '  nvm reinstall-packages <version>          Reinstall global `npm` packages contained in <version> to current version'
      echo '  nvm unload                                Unload `nvm` from shell'
      echo '  nvm which [<version>]                     Display path to installed node version. Uses .nvmrc if available'
      echo
      echo 'Example:'
      echo '  nvm install v0.10.32                  Install a specific version number'
      echo '  nvm use 0.10                          Use the latest available 0.10.x release'
      echo '  nvm run 0.10.32 app.js                Run app.js using node v0.10.32'
      echo '  nvm exec 0.10.32 node app.js          Run `node app.js` with the PATH pointing to node v0.10.32'
      echo '  nvm alias default 0.10.32             Set default node version on a shell'
      echo
      echo 'Note:'
      echo '  to remove, delete, or uninstall nvm - just remove the `$NVM_DIR` folder (usually `~/.nvm`)'
      echo
    ;;

    "debug" )
      local ZHS_HAS_SHWORDSPLIT_UNSET
      ZHS_HAS_SHWORDSPLIT_UNSET=1
      if nvm_has "setopt"; then
        ZHS_HAS_SHWORDSPLIT_UNSET=$(setopt | command grep shwordsplit > /dev/null ; echo $?)
        setopt shwordsplit
      fi
      echo >&2 "nvm --version: v$(nvm --version)"
      echo >&2 "\$SHELL: $SHELL"
      echo >&2 "\$HOME: $HOME"
      echo >&2 "\$NVM_DIR: '$(nvm_sanitize_path "$NVM_DIR")'"
      echo >&2 "\$PREFIX: '$(nvm_sanitize_path "$PREFIX")'"
      echo >&2 "\$NPM_CONFIG_PREFIX: '$(nvm_sanitize_path "$NPM_CONFIG_PREFIX")'"
      local NVM_DEBUG_OUTPUT
      for NVM_DEBUG_COMMAND in 'nvm current' 'which node' 'which iojs' 'which npm' 'npm config get prefix' 'npm root -g'
      do
        NVM_DEBUG_OUTPUT="$($NVM_DEBUG_COMMAND 2>&1)"
        echo >&2 "$NVM_DEBUG_COMMAND: $(nvm_sanitize_path "$NVM_DEBUG_OUTPUT")"
      done
      if [ "$ZHS_HAS_SHWORDSPLIT_UNSET" -eq 1 ] && nvm_has "unsetopt"; then
        unsetopt shwordsplit
      fi
      return 42
    ;;

    "install" | "i" )
      local version_not_provided
      version_not_provided=0
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
          >&2 nvm help
          return 127
        fi
      fi

      shift

      local nobinary
      nobinary=0
      local make_jobs
      while [ $# -ne 0 ]
      do
        case "$1" in
          -s)
            shift # consume "-s"
            nobinary=1
          ;;
          -j)
            shift # consume "-j"
            nvm_get_make_jobs "$1"
            shift # consume job count
          ;;
          *)
            break # stop parsing args
          ;;
        esac
      done

      local provided_version
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
        case "$1" in
          --reinstall-packages-from=*)
            PROVIDED_REINSTALL_PACKAGES_FROM="$(echo "$1" | command cut -c 27-)"
            REINSTALL_PACKAGES_FROM="$(nvm_version "$PROVIDED_REINSTALL_PACKAGES_FROM")"
          ;;
          --copy-packages-from=*)
            PROVIDED_REINSTALL_PACKAGES_FROM="$(echo "$1" | command cut -c 22-)"
            REINSTALL_PACKAGES_FROM="$(nvm_version "$PROVIDED_REINSTALL_PACKAGES_FROM")"
          ;;
          *)
            ADDITIONAL_PARAMETERS="$ADDITIONAL_PARAMETERS $1"
          ;;
        esac
        shift
      done

      if [ "_$(nvm_ensure_version_prefix "$PROVIDED_REINSTALL_PACKAGES_FROM")" = "_$VERSION" ]; then
        echo "You can't reinstall global packages from the same version of node you're installing." >&2
        return 4
      elif [ ! -z "$PROVIDED_REINSTALL_PACKAGES_FROM" ] && [ "_$REINSTALL_PACKAGES_FROM" = "_N/A" ]; then
        echo "If --reinstall-packages-from is provided, it must point to an installed version of node." >&2
        return 5
      fi

      local NVM_NODE_MERGED
      local NVM_IOJS
      if nvm_is_iojs_version "$VERSION"; then
        NVM_IOJS=true
      elif nvm_is_merged_node_version "$VERSION"; then
        NVM_NODE_MERGED=true
      fi

      local VERSION_PATH
      VERSION_PATH="$(nvm_version_path "$VERSION")"
      if [ -d "$VERSION_PATH" ]; then
        echo "$VERSION is already installed." >&2
        if nvm use "$VERSION" && [ ! -z "$REINSTALL_PACKAGES_FROM" ] && [ "_$REINSTALL_PACKAGES_FROM" != "_N/A" ]; then
          nvm reinstall-packages "$REINSTALL_PACKAGES_FROM"
        fi
        nvm_ensure_default_set "$provided_version"
        return $?
      fi

      if [ "_$NVM_OS" = "_freebsd" ]; then
        # node.js and io.js do not have a FreeBSD binary
        nobinary=1
        echo "Currently, there is no binary for $NVM_OS" >&2
      elif [ "_$NVM_OS" = "_sunos" ]; then
        # Not all node/io.js versions have a Solaris binary
          if ! nvm_has_solaris_binary "$VERSION"; then
            nobinary=1
            echo "Currently, there is no binary of version $VERSION for $NVM_OS" >&2
        fi
      fi
      local NVM_INSTALL_SUCCESS
      # skip binary install if "nobinary" option specified.
      if [ $nobinary -ne 1 ] && nvm_binary_available "$VERSION"; then
        if [ "$NVM_IOJS" = true ] && nvm_install_iojs_binary std "$VERSION" "$REINSTALL_PACKAGES_FROM"; then
          NVM_INSTALL_SUCCESS=true
        elif [ "$NVM_NODE_MERGED" = true ] && nvm_install_merged_node_binary std "$VERSION" "$REINSTALL_PACKAGES_FROM"; then
          NVM_INSTALL_SUCCESS=true
        elif [ "$NVM_IOJS" != true ] && nvm_install_node_binary "$VERSION" "$REINSTALL_PACKAGES_FROM"; then
          NVM_INSTALL_SUCCESS=true
        fi
      fi
      if [ "$NVM_INSTALL_SUCCESS" != true ]; then
        if [ -z "${NVM_MAKE_JOBS-}" ]; then
          nvm_get_make_jobs
        fi
        if [ "$NVM_IOJS" != true ] &&  [ "$NVM_NODE_MERGED" != true ]; then
          if nvm_install_node_source "$VERSION" "$NVM_MAKE_JOBS" "$ADDITIONAL_PARAMETERS"; then
            NVM_INSTALL_SUCCESS=true
          fi
        elif [ "$NVM_IOJS" = true ]; then
          # nvm_install_iojs_source "$VERSION" "$NVM_MAKE_JOBS" "$ADDITIONAL_PARAMETERS"
          echo "Installing iojs from source is not currently supported" >&2
          return 105
        elif [ "$NVM_NODE_MERGED" = true ]; then
         # nvm_install_merged_node_source "$VERSION" "$NVM_MAKE_JOBS" "$ADDITIONAL_PARAMETERS"
         echo "Installing node v1.0 and greater from source is not currently supported" >&2
         return 106
        fi
      fi

      if [ "$NVM_INSTALL_SUCCESS" = true ] && nvm use "$VERSION"; then
        nvm_ensure_default_set "$provided_version"
        if [ ! -z "$REINSTALL_PACKAGES_FROM" ] \
          && [ "_$REINSTALL_PACKAGES_FROM" != "_N/A" ]; then
          nvm reinstall-packages "$REINSTALL_PACKAGES_FROM"
        fi
      fi
      return $?
    ;;
    "uninstall" )
      if [ $# -ne 2 ]; then
        >&2 nvm help
        return 127
      fi

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
        NVM_SUCCESS_MSG="Uninstalled io.js $(nvm_strip_iojs_prefix "$VERSION")"
      else
        NVM_PREFIX="$(nvm_node_prefix)"
        NVM_SUCCESS_MSG="Uninstalled node $VERSION"
      fi
      # Delete all files related to target version.
      command rm -rf "$NVM_DIR/src/$NVM_PREFIX-$VERSION" \
             "$NVM_DIR/src/$NVM_PREFIX-$VERSION.tar.*" \
             "$NVM_DIR/bin/$NVM_PREFIX-${t}" \
             "$NVM_DIR/bin/$NVM_PREFIX-${t}.tar.*" \
             "$VERSION_PATH" 2>/dev/null
      echo "$NVM_SUCCESS_MSG"

      # rm any aliases that point to uninstalled version.
      for ALIAS in $(command grep -l "$VERSION" "$(nvm_alias_path)/*" 2>/dev/null)
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

      if [ -n "${MANPATH-}" ]; then
        NEWPATH="$(nvm_strip_path "$MANPATH" "/share/man")"
        if [ "_$MANPATH" = "_$NEWPATH" ]; then
          echo "Could not find $NVM_DIR/*/share/man in \$MANPATH" >&2
        else
          export MANPATH="$NEWPATH"
          echo "$NVM_DIR/*/share/man removed from \$MANPATH"
        fi
      fi

      if [ -n "${NODE_PATH-}" ]; then
        NEWPATH="$(nvm_strip_path "$NODE_PATH" "/lib/node_modules")"
        if [ "_$NODE_PATH" != "_$NEWPATH" ]; then
          export NODE_PATH="$NEWPATH"
          echo "$NVM_DIR/*/lib/node_modules removed from \$NODE_PATH"
        fi
      fi
    ;;
    "use" )
      local PROVIDED_VERSION
      local NVM_USE_SILENT
      NVM_USE_SILENT=0
      local NVM_DELETE_PREFIX
      NVM_DELETE_PREFIX=0

      shift # remove "use"
      while [ $# -ne 0 ]
      do
        case "$1" in
          --silent) NVM_USE_SILENT=1 ;;
          --delete-prefix) NVM_DELETE_PREFIX=1 ;;
          *)
            if [ -n "$1" ]; then
              PROVIDED_VERSION="$1"
            fi
          ;;
        esac
        shift
      done

      if [ -z "$PROVIDED_VERSION" ]; then
        nvm_rc_version
        if [ -n "$NVM_RC_VERSION" ]; then
          PROVIDED_VERSION="$NVM_RC_VERSION"
          VERSION="$(nvm_version "$PROVIDED_VERSION")"
        fi
      else
        VERSION="$(nvm_match_version "$PROVIDED_VERSION")"
      fi

      if [ -z "$VERSION" ]; then
        >&2 nvm help
        return 127
      fi

      if [ "_$VERSION" = '_system' ]; then
        if nvm_has_system_node && nvm deactivate >/dev/null 2>&1; then
          if [ $NVM_USE_SILENT -ne 1 ]; then
            echo "Now using system version of node: $(node -v 2>/dev/null)$(nvm_print_npm_version)"
          fi
          return
        elif nvm_has_system_iojs && nvm deactivate >/dev/null 2>&1; then
          if [ $NVM_USE_SILENT -ne 1 ]; then
            echo "Now using system version of io.js: $(iojs --version 2>/dev/null)$(nvm_print_npm_version)"
          fi
          return
        else
          if [ $NVM_USE_SILENT -ne 1 ]; then
            echo "System version of node not found." >&2
          fi
          return 127
        fi
      elif [ "_$VERSION" = "_∞" ]; then
        if [ $NVM_USE_SILENT -ne 1 ]; then
          echo "The alias \"$PROVIDED_VERSION\" leads to an infinite loop. Aborting." >&2
        fi
        return 8
      fi

      # This nvm_ensure_version_installed call can be a performance bottleneck
      # on shell startup. Perhaps we can optimize it away or make it faster.
      nvm_ensure_version_installed "$PROVIDED_VERSION"
      EXIT_CODE=$?
      if [ "$EXIT_CODE" != "0" ]; then
        return $EXIT_CODE
      fi

      local NVM_VERSION_DIR
      NVM_VERSION_DIR="$(nvm_version_path "$VERSION")"

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
      if [ "${NVM_SYMLINK_CURRENT-}" = true ]; then
        command rm -f "$NVM_DIR/current" && ln -s "$NVM_VERSION_DIR" "$NVM_DIR/current"
      fi
      local NVM_USE_OUTPUT
      if [ $NVM_USE_SILENT -ne 1 ]; then
        if nvm_is_iojs_version "$VERSION"; then
          NVM_USE_OUTPUT="Now using io.js $(nvm_strip_iojs_prefix "$VERSION")$(nvm_print_npm_version)"
        else
          NVM_USE_OUTPUT="Now using node $VERSION$(nvm_print_npm_version)"
        fi
      fi
      if [ "_$VERSION" != "_system" ]; then
        local NVM_USE_CMD
        NVM_USE_CMD="nvm use --delete-prefix"
        if [ -n "$PROVIDED_VERSION" ]; then
          NVM_USE_CMD="$NVM_USE_CMD $VERSION"
        fi
        if [ $NVM_USE_SILENT -eq 1 ]; then
          NVM_USE_CMD="$NVM_USE_CMD --silent"
        fi
        if ! nvm_die_on_prefix "$NVM_DELETE_PREFIX" "$NVM_USE_CMD"; then
          return 11
        fi
      fi
      if [ -n "$NVM_USE_OUTPUT" ]; then
        echo "$NVM_USE_OUTPUT"
      fi
    ;;
    "run" )
      local provided_version
      local has_checked_nvmrc
      has_checked_nvmrc=0
      # run given version of node
      shift

      local NVM_SILENT
      NVM_SILENT=0
      if [ "_$1" = "_--silent" ]; then
        NVM_SILENT=1
        shift
      fi

      if [ $# -lt 1 ]; then
        if [ "$NVM_SILENT" -eq 1 ]; then
          nvm_rc_version >/dev/null 2>&1 && has_checked_nvmrc=1
        else
          nvm_rc_version && has_checked_nvmrc=1
        fi
        if [ -n "$NVM_RC_VERSION" ]; then
          VERSION="$(nvm_version "$NVM_RC_VERSION")"
        else
          VERSION='N/A'
        fi
        if [ $VERSION = "N/A" ]; then
          >&2 nvm help
          return 127
        fi
      fi

      provided_version="$1"
      if [ -n "$provided_version" ]; then
        VERSION="$(nvm_version "$provided_version")"
        if [ "_$VERSION" = "_N/A" ] && ! nvm_is_valid_version "$provided_version"; then
          provided_version=''
          if [ $has_checked_nvmrc -ne 1 ]; then
            if [ "$NVM_SILENT" -eq 1 ]; then
              nvm_rc_version >/dev/null 2>&1 && has_checked_nvmrc=1
            else
              nvm_rc_version && has_checked_nvmrc=1
            fi
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
        nvm_ensure_version_installed "$provided_version"
        EXIT_CODE=$?
      elif [ -z "$ARGS" ]; then
        if [ "$NVM_IOJS" = true ]; then
          nvm exec "$VERSION" iojs
        else
          nvm exec "$VERSION" node
        fi
        EXIT_CODE="$?"
      elif [ "$NVM_IOJS" = true ]; then
        [ $NVM_SILENT -eq 1 ] || echo "Running io.js $(nvm_strip_iojs_prefix "$VERSION")$(nvm use --silent "$VERSION" && nvm_print_npm_version)"
        OUTPUT="$(nvm use "$VERSION" >/dev/null && iojs $ARGS)"
        EXIT_CODE="$?"
      else
        [ $NVM_SILENT -eq 1 ] || echo "Running node $VERSION$(nvm use --silent "$VERSION" && nvm_print_npm_version)"
        OUTPUT="$(nvm use "$VERSION" >/dev/null && node $ARGS)"
        EXIT_CODE="$?"
      fi
      if [ "$ZHS_HAS_SHWORDSPLIT_UNSET" -eq 1 ] && nvm_has "unsetopt"; then
        unsetopt shwordsplit
      fi
      if [ -n "$OUTPUT" ]; then
        echo "$OUTPUT"
      fi
      return $EXIT_CODE
    ;;
    "exec" )
      shift

      local NVM_SILENT
      NVM_SILENT=0
      if [ "_$1" = "_--silent" ]; then
        NVM_SILENT=1
        shift
      fi

      local provided_version
      provided_version="$1"
      if [ -n "$provided_version" ]; then
        VERSION="$(nvm_version "$provided_version")"
        if [ "_$VERSION" = "_N/A" ] && ! nvm_is_valid_version "$provided_version"; then
          if [ "$NVM_SILENT" -eq 1 ]; then
            nvm_rc_version >/dev/null 2>&1
          else
            nvm_rc_version
          fi
          provided_version="$NVM_RC_VERSION"
          VERSION="$(nvm_version "$provided_version")"
        else
          shift
        fi
      fi

      nvm_ensure_version_installed "$provided_version"
      EXIT_CODE=$?
      if [ "$EXIT_CODE" != "0" ]; then
        return $EXIT_CODE
      fi

      [ $NVM_SILENT -eq 1 ] || echo "Running node $VERSION$(nvm use --silent "$VERSION" && nvm_print_npm_version)"
      NODE_VERSION="$VERSION" "$NVM_DIR/nvm-exec" "$@"
    ;;
    "ls" | "list" )
      local NVM_LS_OUTPUT
      local NVM_LS_EXIT_CODE
      NVM_LS_OUTPUT=$(nvm_ls "${2-}")
      NVM_LS_EXIT_CODE=$?
      nvm_print_versions "$NVM_LS_OUTPUT"
      if [ $# -eq 1 ]; then
        nvm alias
      fi
      return $NVM_LS_EXIT_CODE
    ;;
    "ls-remote" | "list-remote" )
      local PATTERN
      PATTERN="${2-}"
      local NVM_IOJS_PREFIX
      NVM_IOJS_PREFIX="$(nvm_iojs_prefix)"
      local NVM_NODE_PREFIX
      NVM_NODE_PREFIX="$(nvm_node_prefix)"
      local NVM_FLAVOR
      case "_$PATTERN" in
        "_$NVM_IOJS_PREFIX" | "_$NVM_NODE_PREFIX" )
          NVM_FLAVOR="$PATTERN"
          PATTERN="$3"
        ;;
      esac

      local NVM_LS_REMOTE_EXIT_CODE
      NVM_LS_REMOTE_EXIT_CODE=0
      local NVM_LS_REMOTE_PRE_MERGED_OUTPUT
      NVM_LS_REMOTE_PRE_MERGED_OUTPUT=''
      local NVM_LS_REMOTE_POST_MERGED_OUTPUT
      NVM_LS_REMOTE_POST_MERGED_OUTPUT=''
      if [ "_$NVM_FLAVOR" != "_$NVM_IOJS_PREFIX" ]; then
        local NVM_LS_REMOTE_OUTPUT
        NVM_LS_REMOTE_OUTPUT=$(nvm_ls_remote "$PATTERN")
        # split output into two
        NVM_LS_REMOTE_PRE_MERGED_OUTPUT="${NVM_LS_REMOTE_OUTPUT%%v4\.0\.0*}"
        NVM_LS_REMOTE_POST_MERGED_OUTPUT="${NVM_LS_REMOTE_OUTPUT#$NVM_LS_REMOTE_PRE_MERGED_OUTPUT}"
        NVM_LS_REMOTE_EXIT_CODE=$?
      fi

      local NVM_LS_REMOTE_IOJS_EXIT_CODE
      NVM_LS_REMOTE_IOJS_EXIT_CODE=0
      local NVM_LS_REMOTE_IOJS_OUTPUT
      NVM_LS_REMOTE_IOJS_OUTPUT=''
      if [ "_$NVM_FLAVOR" != "_$NVM_NODE_PREFIX" ]; then
        NVM_LS_REMOTE_IOJS_OUTPUT=$(nvm_ls_remote_iojs "$PATTERN")
        NVM_LS_REMOTE_IOJS_EXIT_CODE=$?
      fi

      local NVM_OUTPUT
      NVM_OUTPUT="$(echo "$NVM_LS_REMOTE_PRE_MERGED_OUTPUT
$NVM_LS_REMOTE_IOJS_OUTPUT
$NVM_LS_REMOTE_POST_MERGED_OUTPUT" | command grep -v "N/A" | command sed '/^$/d')"
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
      local provided_version
      provided_version="$2"
      if [ $# -eq 1 ]; then
        nvm_rc_version
        if [ -n "$NVM_RC_VERSION" ]; then
          provided_version="$NVM_RC_VERSION"
          VERSION=$(nvm_version "$NVM_RC_VERSION")
        fi
      elif [ "_$2" != '_system' ]; then
        VERSION="$(nvm_version "$provided_version")"
      else
        VERSION="$2"
      fi
      if [ -z "$VERSION" ]; then
        >&2 nvm help
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

      nvm_ensure_version_installed "$provided_version"
      EXIT_CODE=$?
      if [ "$EXIT_CODE" != "0" ]; then
        return $EXIT_CODE
      fi
      local NVM_VERSION_DIR
      NVM_VERSION_DIR="$(nvm_version_path "$VERSION")"
      echo "$NVM_VERSION_DIR/bin/node"
    ;;
    "alias" )
      local NVM_ALIAS_DIR
      NVM_ALIAS_DIR="$(nvm_alias_path)"
      command mkdir -p "$NVM_ALIAS_DIR"
      if [ $# -le 2 ]; then
        local DEST
        for ALIAS_PATH in "$NVM_ALIAS_DIR"/"${2-}"*; do
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
                if [ "_$DEST" = "_$VERSION" ]; then
                  echo "$ALIAS -> $DEST (default)"
                else
                  echo "$ALIAS -> $DEST (-> $VERSION) (default)"
                fi
              fi
            fi
          fi
        done
        return
      fi
      if [ -z "${3-}" ]; then
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
      if [ $# -ne 2 ]; then
        >&2 nvm help
        return 127
      fi
      [ ! -f "$NVM_ALIAS_DIR/$2" ] && echo "Alias $2 doesn't exist!" >&2 && return
      local NVM_ALIAS_ORIGINAL
      NVM_ALIAS_ORIGINAL="$(nvm_alias "$2")"
      command rm -f "$NVM_ALIAS_DIR/$2"
      echo "Deleted alias $2 - restore it with \`nvm alias $2 "$NVM_ALIAS_ORIGINAL"\`"
    ;;
    "reinstall-packages" | "copy-packages" )
      if [ $# -ne 2 ]; then
        >&2 nvm help
        return 127
      fi

      local PROVIDED_VERSION
      PROVIDED_VERSION="$2"

      if [ "$PROVIDED_VERSION" = "$(nvm_ls_current)" ] || [ "$(nvm_version "$PROVIDED_VERSION")" = "$(nvm_ls_current)" ]; then
        echo 'Can not reinstall packages from the current version of node.' >&2
        return 2
      fi

      local VERSION
      if [ "_$PROVIDED_VERSION" = "_system" ]; then
        if ! nvm_has_system_node && ! nvm_has_system_iojs; then
          echo 'No system version of node or io.js detected.' >&2
          return 3
        fi
        VERSION="system"
      else
        VERSION="$(nvm_version "$PROVIDED_VERSION")"
      fi

      local NPMLIST
      NPMLIST="$(nvm_npm_global_modules "$VERSION")"
      local INSTALLS
      local LINKS
      INSTALLS="${NPMLIST%% //// *}"
      LINKS="${NPMLIST##* //// }"

      echo "Reinstalling global packages from $VERSION..."
      echo "$INSTALLS" | command xargs npm install -g --quiet

      echo "Linking global packages from $VERSION..."
      set -f; IFS='
' # necessary to turn off variable expansion except for newlines
      for LINK in $LINKS; do
        set +f; unset IFS # restore variable expansion
        if [ -n "$LINK" ]; then
          (cd "$LINK" && npm link)
        fi
      done
      set +f; unset IFS # restore variable expansion in case $LINKS was empty
    ;;
    "clear-cache" )
      command rm -f "$NVM_DIR/v*" "$(nvm_version_dir)" 2>/dev/null
      echo "Cache cleared."
    ;;
    "version" )
      nvm_version "$2"
    ;;
    "version-remote" )
      nvm_remote_version "$2"
    ;;
    "--version" )
      echo "0.31.0"
    ;;
    "unload" )
      unset -f nvm nvm_print_versions nvm_checksum \
        nvm_iojs_prefix nvm_node_prefix \
        nvm_add_iojs_prefix nvm_strip_iojs_prefix \
        nvm_is_iojs_version nvm_is_alias \
        nvm_ls_remote nvm_ls_remote_iojs nvm_ls_remote_index_tab \
        nvm_ls nvm_remote_version nvm_remote_versions \
        nvm_install_iojs_binary nvm_install_node_binary \
        nvm_install_node_source \
        nvm_version nvm_rc_version nvm_match_version \
        nvm_ensure_default_set nvm_get_arch nvm_get_os \
        nvm_print_implicit_alias nvm_validate_implicit_alias \
        nvm_resolve_alias nvm_ls_current nvm_alias \
        nvm_binary_available nvm_prepend_path nvm_strip_path \
        nvm_num_version_groups nvm_format_version nvm_ensure_version_prefix \
        nvm_normalize_version nvm_is_valid_version \
        nvm_ensure_version_installed \
        nvm_version_path nvm_alias_path nvm_version_dir \
        nvm_find_nvmrc nvm_find_up nvm_tree_contains_path \
        nvm_version_greater nvm_version_greater_than_or_equal_to \
        nvm_print_npm_version nvm_npm_global_modules \
        nvm_has_system_node nvm_has_system_iojs \
        nvm_download nvm_get_latest nvm_has nvm_get_latest \
        nvm_supports_source_options nvm_auto nvm_supports_xz \
        nvm_process_parameters > /dev/null 2>&1
      unset RC_VERSION NVM_NODEJS_ORG_MIRROR NVM_DIR NVM_CD_FLAGS > /dev/null 2>&1
    ;;
    * )
      >&2 nvm help
      return 127
    ;;
  esac
}

nvm_supports_source_options() {
  [ "_$(echo '[ $# -gt 0 ] && echo $1' | . /dev/stdin yes 2> /dev/null)" = "_yes" ]
}

nvm_supports_xz() {
  command which xz >/dev/null 2>&1 && nvm_version_greater_than_or_equal_to "$1" "2.3.2"
}

nvm_auto() {
  local NVM_MODE
  NVM_MODE="${1-}"
  local VERSION
  if [ "_$NVM_MODE" = '_install' ]; then
    VERSION="$(nvm_alias default 2>/dev/null || echo)"
    if [ -n "$VERSION" ]; then
      nvm install "$VERSION" >/dev/null
    elif nvm_rc_version >/dev/null 2>&1; then
      nvm install >/dev/null
    fi
  elif [ "_$NVM_MODE" = '_use' ]; then
    VERSION="$(nvm_alias default 2>/dev/null || echo)"
    if [ -n "$VERSION" ]; then
      nvm use --silent "$VERSION" >/dev/null
    elif nvm_rc_version >/dev/null 2>&1; then
      nvm use --silent >/dev/null
    fi
  elif [ "_$NVM_MODE" != '_none' ]; then
    echo >&2 'Invalid auto mode supplied.'
    return 1
  fi
}

nvm_process_parameters() {
  local NVM_AUTO_MODE
  NVM_AUTO_MODE='use'
  if nvm_supports_source_options; then
    while [ $# -ne 0 ]
    do
      case "$1" in
        --install) NVM_AUTO_MODE='install' ;;
        --no-use) NVM_AUTO_MODE='none' ;;
      esac
      shift
    done
  fi
  nvm_auto "$NVM_AUTO_MODE"
}

nvm_process_parameters "$@"

} # this ensures the entire script is downloaded #
