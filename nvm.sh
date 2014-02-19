# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

has() {
  type "$1" > /dev/null 2>&1
  return $?
}

# Make zsh glob matching behave same as bash
# This fixes the "zsh: no matches found" errors
if has "unsetopt"; then
  unsetopt nomatch 2>/dev/null
  NVM_CD_FLAGS="-q"
fi

# Auto detect the NVM_DIR
if [ ! -d "$NVM_DIR" ]; then
  if [ -n "$BASH_SOURCE" ]; then
    export NVM_DIR=$(cd $NVM_CD_FLAGS $(dirname ${BASH_SOURCE[0]:-$0}) > /dev/null && pwd)
  else
    export NVM_DIR=$HOME/.nvm
  fi
fi

# Setup mirror location if not already set
if [ -z "$NVM_NODEJS_ORG_MIRROR" ]; then
  export NVM_NODEJS_ORG_MIRROR="http://nodejs.org/dist"
fi

nvm_set_nullglob() {
  if has "setopt"; then
    # Zsh
    setopt NULL_GLOB
  elif has "shopt"; then
    # Bash
    shopt -s nullglob
  fi
}

# Obtain nvm version from rc file
rc_nvm_version() {
  if [ -e .nvmrc ]; then
    RC_VERSION=`cat .nvmrc | head -n 1`
    echo "Found .nvmrc files with version <$RC_VERSION>"
  fi
}

# Expand a version using the version cache
nvm_version() {
  local PATTERN=$1
  local VERSION
  # The default version is the current one
  if [ ! "$PATTERN" ]; then
    PATTERN='current'
  fi

  VERSION=`nvm_ls $PATTERN`
  echo "$VERSION"

  if [ "$VERSION" = 'N/A' ]; then
    return
  fi
}

nvm_remote_version() {
  local PATTERN=$1
  local VERSION
  VERSION=`nvm_ls_remote $PATTERN | tail -n1`
  echo "$VERSION"

  if [ "$VERSION" = 'N/A' ]; then
    return
  fi
}

nvm_ls() {
  local PATTERN=$1
  local VERSIONS=''
  if [ "$PATTERN" = 'current' ]; then
    echo `node -v 2>/dev/null`
    return
  fi

  if [ -f "$NVM_DIR/alias/$PATTERN" ]; then
    nvm_version `cat $NVM_DIR/alias/$PATTERN`
    return
  fi
  # If it looks like an explicit version, don't do anything funny
  if [ `expr "$PATTERN" : "v.*.\?.*.\?.*$"` != 0 ]; then
    VERSIONS="$PATTERN"
  else
    VERSIONS=`find "$NVM_DIR/" -maxdepth 1 -type d -name "v$PATTERN*" -exec basename '{}' ';' \
      | sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n`
  fi
  if [ ! "$VERSIONS" ]; then
      echo "N/A"
      return
  fi
  printf "$VERSIONS\n"
  return
}

nvm_ls_remote() {
  local PATTERN=$1
  local VERSIONS
  if [ "$PATTERN" ]; then
    if echo "${PATTERN}" | \grep -v '^v' ; then
      PATTERN=v$PATTERN
    fi
  else
    PATTERN=".*"
  fi
  VERSIONS=`curl -s $NVM_NODEJS_ORG_MIRROR/ \
              | \egrep -o 'v[0-9]+\.[0-9]+\.[0-9]+' \
              | \grep -w "${PATTERN}" \
              | sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n`
  if [ ! "$VERSIONS" ]; then
    echo "N/A"
    return
  fi
  echo "$VERSIONS"
  return
}

nvm_checksum() {
  if [ "$1" = "$2" ]; then
    return
  elif [ -z $2 ]; then
    echo 'Checksums empty' #missing in raspberry pi binary
    return
  else
    echo 'Checksums do not match.'
    return 1
  fi
}

colorize_version() {
  local VERSION=$1
  echo -e "\033[0;34m$VERSION\033[0m"
}

print_versions() {
  local VERSION
  local PADDED_VERSION
  for VERSION in $1; do
    PADDED_VERSION=`printf '%10s' $VERSION`
    if [ -d "$NVM_DIR/$VERSION" ]; then
      colorize_version "$PADDED_VERSION"
    else
      echo "$PADDED_VERSION"
    fi
  done
}

nvm() {
  if [ $# -lt 1 ]; then
    nvm help
    return
  fi

  # Try to figure out the os and arch for binary fetching
  local uname="$(uname -a)"
  local os=
  local arch="$(uname -m)"
  case "$uname" in
    Linux\ *) os=linux ;;
    Darwin\ *) os=darwin ;;
    SunOS\ *) os=sunos ;;
    FreeBSD\ *) os=freebsd ;;
  esac
  case "$uname" in
    *x86_64*) arch=x64 ;;
    *i*86*) arch=x86 ;;
    *armv6l*) arch=arm-pi ;;
  esac

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
      echo "    nvm help                    Show this message"
      echo "    nvm install [-s] <version>  Download and install a <version>, [-s] from source"
      echo "    nvm uninstall <version>     Uninstall a version"
      echo "    nvm use <version>           Modify PATH to use <version>"
      echo "    nvm run <version> [<args>]  Run <version> with <args> as arguments"
      echo "    nvm current                 Display currently activated version"
      echo "    nvm ls                      List installed versions"
      echo "    nvm ls <version>            List versions matching a given description"
      echo "    nvm ls-remote               List remote versions available for install"
      echo "    nvm deactivate              Undo effects of NVM on current shell"
      echo "    nvm alias [<pattern>]       Show all aliases beginning with <pattern>"
      echo "    nvm alias <name> <version>  Set an alias named <name> pointing to <version>"
      echo "    nvm unalias <name>          Deletes the alias named <name>"
      echo "    nvm copy-packages <version> Install global NPM packages contained in <version> to current version"
      echo
      echo "Example:"
      echo "    nvm install v0.10.24        Install a specific version number"
      echo "    nvm use 0.10                Use the latest available 0.10.x release"
      echo "    nvm run 0.10.24 myApp.js    Run myApp.js using node v0.10.24"
      echo "    nvm alias default 0.10.24   Set default node version on a shell"
      echo
      echo "Note:"
      echo "    to remove, delete or uninstall nvm - just remove ~/.nvm, ~/.npm and ~/.bower folders"
      echo
    ;;

    "install" )
      # initialize local variables
      local binavail
      local t
      local url
      local sum
      local tarball
      local shasum='shasum'
      local nobinary

      if ! has "curl"; then
        echo 'NVM Needs curl to proceed.' >&2;
      fi

      if ! has "shasum"; then
        shasum='sha1sum'
      fi

      if [ $# -lt 2 ]; then
        nvm help
        return
      fi

      shift

      nobinary=0
      if [ "$1" = "-s" ]; then
        nobinary=1
        shift
      fi

      if [ "$os" = "freebsd" ]; then
        nobinary=1
      fi

      [ -d "$NVM_DIR/$1" ] && echo "$1 is already installed." && return

      VERSION=`nvm_remote_version $1`
      ADDITIONAL_PARAMETERS=''

      shift

      while [ $# -ne 0 ]
      do
        ADDITIONAL_PARAMETERS="$ADDITIONAL_PARAMETERS $1"
        shift
      done

      [ -d "$NVM_DIR/$VERSION" ] && echo "$VERSION is already installed." && return

      # skip binary install if no binary option specified.
      if [ $nobinary -ne 1 ]; then
        # shortcut - try the binary if possible.
        if [ -n "$os" ]; then
          binavail=
          # binaries started with node 0.8.6
          case "$VERSION" in
            v0.8.[012345]) binavail=0 ;;
            v0.[1234567].*) binavail=0 ;;
            *) binavail=1 ;;
          esac
          if [ $binavail -eq 1 ]; then
            t="$VERSION-$os-$arch"
            url="$NVM_NODEJS_ORG_MIRROR/$VERSION/node-${t}.tar.gz"
            sum=`curl -s $NVM_NODEJS_ORG_MIRROR/$VERSION/SHASUMS.txt | \grep node-${t}.tar.gz | awk '{print $1}'`
            local tmpdir="$NVM_DIR/bin/node-${t}"
            local tmptarball="$tmpdir/node-${t}.tar.gz"
            if (
              mkdir -p "$tmpdir" && \
              curl -L -C - --progress-bar $url -o "$tmptarball" && \
              nvm_checksum `${shasum} "$tmptarball" | awk '{print $1}'` $sum && \
              tar -xzf "$tmptarball" -C "$tmpdir" --strip-components 1 && \
              rm -f "$tmptarball" && \
              mv "$tmpdir" "$NVM_DIR/$VERSION"
              )
            then
              nvm use $VERSION
              return;
            else
              echo "Binary download failed, trying source." >&2
              rm -rf "$tmptarball" "$tmpdir"
            fi
          fi
        fi
      fi

      echo "Additional options while compiling: $ADDITIONAL_PARAMETERS"

      tarball=''
      sum=''
      make='make'
      if [ "$os" = "freebsd" ]; then
        make='gmake'
      fi
      local tmpdir="$NVM_DIR/src"
      local tmptarball="$tmpdir/node-$VERSION.tar.gz"
      if [ "`curl -Is "$NVM_NODEJS_ORG_MIRROR/$VERSION/node-$VERSION.tar.gz" | \grep '200 OK'`" != '' ]; then
        tarball="$NVM_NODEJS_ORG_MIRROR/$VERSION/node-$VERSION.tar.gz"
        sum=`curl -s $NVM_NODEJS_ORG_MIRROR/$VERSION/SHASUMS.txt | \grep node-$VERSION.tar.gz | awk '{print $1}'`
      elif [ "`curl -Is "$NVM_NODEJS_ORG_MIRROR/node-$VERSION.tar.gz" | \grep '200 OK'`" != '' ]; then
        tarball="$NVM_NODEJS_ORG_MIRROR/node-$VERSION.tar.gz"
      fi
      if (
        [ ! -z $tarball ] && \
        mkdir -p "$tmpdir" && \
        curl -L --progress-bar $tarball -o "$tmptarball" && \
        if [ "$sum" = "" ]; then : ; else nvm_checksum `${shasum} "$tmptarball" | awk '{print $1}'` $sum; fi && \
        tar -xzf "$tmptarball" -C "$tmpdir" && \
        cd "$tmpdir/node-$VERSION" && \
        ./configure --prefix="$NVM_DIR/$VERSION" $ADDITIONAL_PARAMETERS && \
        $make && \
        rm -f "$NVM_DIR/$VERSION" 2>/dev/null && \
        $make install
        )
      then
        nvm use $VERSION
        if ! has "npm" ; then
          echo "Installing npm..."
          if [ "`expr match $VERSION '\(^v0\.1\.\)'`" != '' ]; then
            echo "npm requires node v0.2.3 or higher"
          elif [ "`expr match $VERSION '\(^v0\.2\.\)'`" != '' ]; then
            if [ "`expr match $VERSION '\(^v0\.2\.[0-2]$\)'`" != '' ]; then
              echo "npm requires node v0.2.3 or higher"
            else
              curl https://npmjs.org/install.sh | clean=yes npm_install=0.2.19 sh
            fi
          else
            curl https://npmjs.org/install.sh | clean=yes sh
          fi
        fi
      else
        echo "nvm: install $VERSION failed!"
        return 1
      fi
    ;;
    "uninstall" )
      [ $# -ne 2 ] && nvm help && return
      if [ $2 == `nvm_version` ]; then
        echo "nvm: Cannot uninstall currently-active node version, $2."
        return 1
      fi
      VERSION=`nvm_version $2`
      if [ ! -d $NVM_DIR/$VERSION ]; then
        echo "$VERSION version is not installed..."
        return;
      fi

      t="$VERSION-$os-$arch"

      # Delete all files related to target version.
      rm -rf "$NVM_DIR/src/node-$VERSION" \
             "$NVM_DIR/src/node-$VERSION.tar.gz" \
             "$NVM_DIR/bin/node-${t}" \
             "$NVM_DIR/bin/node-${t}.tar.gz" \
             "$NVM_DIR/$VERSION" 2>/dev/null
      echo "Uninstalled node $VERSION"

      # Rm any aliases that point to uninstalled version.
      for ALIAS in `\grep -l $VERSION $NVM_DIR/alias/* 2>/dev/null`
      do
        nvm unalias `basename $ALIAS`
      done

    ;;
    "deactivate" )
      if [ `expr $PATH : ".*$NVM_DIR/.*/bin.*"` != 0 ] ; then
        export PATH=${PATH%$NVM_DIR/*/bin*}${PATH#*$NVM_DIR/*/bin:}
        hash -r
        echo "$NVM_DIR/*/bin removed from \$PATH"
      else
        echo "Could not find $NVM_DIR/*/bin in \$PATH"
      fi
      if [ `expr $MANPATH : ".*$NVM_DIR/.*/share/man.*"` != 0 ] ; then
        export MANPATH=${MANPATH%$NVM_DIR/*/share/man*}${MANPATH#*$NVM_DIR/*/share/man:}
        echo "$NVM_DIR/*/share/man removed from \$MANPATH"
      else
        echo "Could not find $NVM_DIR/*/share/man in \$MANPATH"
      fi
      if [ `expr $NODE_PATH : ".*$NVM_DIR/.*/lib/node_modules.*"` != 0 ] ; then
        export NODE_PATH=${NODE_PATH%$NVM_DIR/*/lib/node_modules*}${NODE_PATH#*$NVM_DIR/*/lib/node_modules:}
        echo "$NVM_DIR/*/lib/node_modules removed from \$NODE_PATH"
      else
        echo "Could not find $NVM_DIR/*/lib/node_modules in \$NODE_PATH"
      fi
    ;;
    "use" )
      if [ $# -eq 0 ]; then
        nvm help
        return
      fi
      if [ $# -eq 1 ]; then
        rc_nvm_version
        if [ ! -z $RC_VERSION ]; then
            VERSION=`nvm_version $RC_VERSION`
        fi
      else
        VERSION=`nvm_version $2`
      fi
      if [ -z $VERSION ]; then
        nvm help
        return
      fi
      if [ -z $VERSION ]; then
        VERSION=`nvm_version $2`
      fi
      if [ ! -d "$NVM_DIR/$VERSION" ]; then
        echo "$VERSION version is not installed yet"
        return 1
      fi
      if [ `expr $PATH : ".*$NVM_DIR/.*/bin"` != 0 ]; then
        PATH=${PATH%$NVM_DIR/*/bin*}$NVM_DIR/$VERSION/bin${PATH#*$NVM_DIR/*/bin}
      else
        PATH="$NVM_DIR/$VERSION/bin:$PATH"
      fi
      if [ -z "$MANPATH" ]; then
        MANPATH=$(manpath)
      fi
      MANPATH=${MANPATH#*$NVM_DIR/*/man:}
      if [ `expr $MANPATH : ".*$NVM_DIR/.*/share/man"` != 0 ]; then
        MANPATH=${MANPATH%$NVM_DIR/*/share/man*}$NVM_DIR/$VERSION/share/man${MANPATH#*$NVM_DIR/*/share/man}
      else
        MANPATH="$NVM_DIR/$VERSION/share/man:$MANPATH"
      fi
      if [ `expr $NODE_PATH : ".*$NVM_DIR/.*/lib/node_modules.*"` != 0 ]; then
        NODE_PATH=${NODE_PATH%$NVM_DIR/*/lib/node_modules*}$NVM_DIR/$VERSION/lib/node_modules${NODE_PATH#*$NVM_DIR/*/lib/node_modules}
      else
        NODE_PATH="$NVM_DIR/$VERSION/lib/node_modules:$NODE_PATH"
      fi
      export PATH
      hash -r
      export MANPATH
      export NODE_PATH
      export NVM_PATH="$NVM_DIR/$VERSION/lib/node"
      export NVM_BIN="$NVM_DIR/$VERSION/bin"
      echo "Now using node $VERSION"
    ;;
    "run" )
      # run given version of node
      if [ $# -lt 2 ]; then
        nvm help
        return
      fi
      VERSION=`nvm_version $2`
      if [ ! -d $NVM_DIR/$VERSION ]; then
        echo "$VERSION version is not installed yet"
        return;
      fi
      if [ `expr $NODE_PATH : ".*$NVM_DIR/.*/lib/node_modules.*"` != 0 ]; then
        RUN_NODE_PATH=${NODE_PATH%$NVM_DIR/*/lib/node_modules*}$NVM_DIR/$VERSION/lib/node_modules${NODE_PATH#*$NVM_DIR/*/lib/node_modules}
      else
        RUN_NODE_PATH="$NVM_DIR/$VERSION/lib/node_modules:$NODE_PATH"
      fi
      echo "Running node $VERSION"
      NODE_PATH=$RUN_NODE_PATH $NVM_DIR/$VERSION/bin/node "${@:3}"
    ;;
    "ls" | "list" )
      print_versions "`nvm_ls $2`"
      if [ $# -eq 1 ]; then
        printf "current: \t"; nvm_version current
        nvm alias
      fi
      return
    ;;
    "ls-remote" | "list-remote" )
        print_versions "`nvm_ls_remote $2`"
        return
    ;;
    "current" )
      echo -ne "current: \t"; nvm_version current
    ;;
    "alias" )
      mkdir -p $NVM_DIR/alias
      if [ $# -le 2 ]; then
        local DEST
        for ALIAS in $(nvm_set_nullglob; echo $NVM_DIR/alias/$2* ); do
            DEST=`cat $ALIAS`
            VERSION=`nvm_version $DEST`
            if [ "$DEST" = "$VERSION" ]; then
                echo "$(basename $ALIAS) -> $DEST"
            else
                echo "$(basename $ALIAS) -> $DEST (-> $VERSION)"
            fi
        done
        return
      fi
      if [ ! "$3" ]; then
          rm -f $NVM_DIR/alias/$2
          echo "$2 -> *poof*"
          return
      fi
      mkdir -p $NVM_DIR/alias
      VERSION=`nvm_version $3`
      if [ $? -ne 0 ]; then
        echo "! WARNING: Version '$3' does not exist." >&2
      fi
      echo $3 > "$NVM_DIR/alias/$2"
      if [ ! "$3" = "$VERSION" ]; then
          echo "$2 -> $3 (-> $VERSION)"
      else
        echo "$2 -> $3"
      fi
    ;;
    "unalias" )
      mkdir -p $NVM_DIR/alias
      [ $# -ne 2 ] && nvm help && return
      [ ! -f $NVM_DIR/alias/$2 ] && echo "Alias $2 doesn't exist!" && return
      rm -f $NVM_DIR/alias/$2
      echo "Deleted alias $2"
    ;;
    "copy-packages" )
        if [ $# -ne 2 ]; then
          nvm help
          return
        fi
        VERSION=`nvm_version $2`
        local ROOT=`(nvm use $VERSION && npm -g root)`
        local ROOTDEPTH=$((`echo $ROOT | sed 's/[^\/]//g'|wc -m` -1))

        # declare local INSTALLS first, otherwise it doesn't work in zsh
        local INSTALLS
        INSTALLS=`nvm use $VERSION > /dev/null && npm -g -p ll | \grep "$ROOT\/[^/]\+$" | cut -d '/' -f $(($ROOTDEPTH + 2)) | cut -d ":" -f 2 | \grep -v npm | tr "\n" " "`

        npm install -g ${INSTALLS[@]}
    ;;
    "clear-cache" )
        rm -f $NVM_DIR/v* 2>/dev/null
        echo "Cache cleared."
    ;;
    "version" )
        colorize_version "`nvm_version $2`"
    ;;
    * )
      nvm help
    ;;
  esac
}

nvm ls default >/dev/null && nvm use default >/dev/null || true

