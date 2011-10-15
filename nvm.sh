# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

# Auto detect the NVM_DIR
if [ ! -d "$NVM_DIR" ]; then
    export NVM_DIR=$(cd $(dirname ${BASH_SOURCE[0]:-$0}); pwd)
fi

# Emulate curl with wget, if necessary
if [ ! `which curl` ]; then
    if [ `which wget` ]; then
        curl() {
            ARGS="$* "
            ARGS=${ARGS/-s /-q }
            ARGS=${ARGS/--progress-bar /}
            ARGS=${ARGS/-C - /-c }
            ARGS=${ARGS/-o /-O }

            wget $ARGS
        }
    else
        NOCURL='nocurl'
        curl() { echo 'Need curl or wget to proceed.' >&2; }
    fi
fi

# Expand a version using the version cache
nvm_version()
{
    PATTERN=$1
    VERSION=''
    if [ -f "$NVM_DIR/alias/$PATTERN" ]; then
        nvm_version `cat $NVM_DIR/alias/$PATTERN`
        return
    fi
    # If it looks like an explicit version, don't do anything funny
    if [[ "$PATTERN" == v?*.?*.?* ]]; then
        VERSION="$PATTERN"
    fi
    # The default version is the current one
    if [ ! "$PATTERN" -o "$PATTERN" = 'current' ]; then
        VERSION=`node -v 2>/dev/null`
    fi
    if [ "$PATTERN" = 'all' ]; then
        (cd $NVM_DIR; \ls -dG v* 2>/dev/null || echo "N/A")
        return
    fi
    if [ ! "$VERSION" ]; then
        VERSION=`(cd $NVM_DIR; \ls -d v${PATTERN}* 2>/dev/null) | sort -t. -k 2,1n -k 2,2n -k 3,3n | tail -n1`
    fi
    if [ ! "$VERSION" ]; then
        echo "N/A"
        return 13
    elif [ -e "$NVM_DIR/$VERSION" ]; then
        (cd $NVM_DIR; \ls -dG "$VERSION")
    else
        echo "$VERSION"
    fi
}

nvm()
{
  if [ $# -lt 1 ]; then
    nvm help
    return
  fi
  case $1 in
    "help" )
      echo
      echo "Node Version Manager"
      echo
      echo "Usage:"
      echo "    nvm help                    Show this message"
      echo "    nvm install <version>       Download and install a <version>"
      echo "    nvm uninstall <version>     Uninstall a version"
      echo "    nvm use <version>           Modify PATH to use <version>"
      echo "    nvm ls                      List installed versions"
      echo "    nvm ls <version>            List versions matching a given description"
      echo "    nvm deactivate              Undo effects of NVM on current shell"
      echo "    nvm alias [<pattern>]       Show all aliases beginning with <pattern>"
      echo "    nvm alias <name> <version>  Set an alias named <name> pointing to <version>"
      echo "    nvm unalias <name>          Deletes the alias named <name>"
      echo "    nvm copy-packages <version> Install global NPM packages contained in <version> to current version"
      echo "    nvm versions                List available versions"
      echo
      echo "Example:"
      echo "    nvm install v0.4.12         Install a specific version number"
      echo "    nvm use 0.2                 Use the latest available 0.2.x release"
      echo "    nvm alias default 0.4       Auto use the latest installed v0.4.x version"
      echo
    ;;
    "install" )
      if [ $# -ne 2 ]; then
        nvm help
        return
      fi
      [ "$NOCURL" ] && curl && return
      if [ $2 == latest ]; then
        VERSION=$(nvm versions | tail -1)
      else
        VERSION=`nvm_version $2`
      fi

      [ -d "$NVM_DIR/$VERSION" ] && echo "$VERSION is already installed." && return

      tarball=''
      if [ "`curl -Is "http://nodejs.org/dist/$VERSION/node-$VERSION.tar.gz" | grep '200 OK'`" != '' ]; then
        tarball="http://nodejs.org/dist/$VERSION/node-$VERSION.tar.gz"
      elif [ "`curl -Is "http://nodejs.org/dist/node-$VERSION.tar.gz" | grep '200 OK'`" != '' ]; then
        tarball="http://nodejs.org/dist/node-$VERSION.tar.gz"
      fi
      if (
        [ ! -z $tarball ] && \
        mkdir -p "$NVM_DIR/src" && \
        cd "$NVM_DIR/src" && \
        curl -C - --progress-bar $tarball -o "node-$VERSION.tar.gz" && \
        tar -xzf "node-$VERSION.tar.gz" && \
        cd "node-$VERSION" && \
        ./configure --prefix="$NVM_DIR/$VERSION" && \
        make && \
        rm -f "$NVM_DIR/$VERSION" 2>/dev/null && \
        make install
        )
      then
        nvm use $VERSION
        if ! which npm ; then
          echo "Installing npm..."
          # TODO: if node version 0.2.x add npm_install=0.2.19 before sh
          curl http://npmjs.org/install.sh | clean=yes sh
        fi
      else
        echo "nvm: install $VERSION failed!"
      fi
    ;;
    "uninstall" )
      [ $# -ne 2 ] && nvm help && return
      if [[ $2 == `nvm_version` ]]; then
        echo "nvm: Cannot uninstall currently-active node version, $2."
        return
      fi
      VERSION=`nvm_version $2`
      if [ ! -d $NVM_DIR/$VERSION ]; then
        echo "$VERSION version is not installed yet"
        return;
      fi

      # Delete all files related to target version.
      (mkdir -p "$NVM_DIR/src" && \
          cd "$NVM_DIR/src" && \
          rm -rf "node-$VERSION" 2>/dev/null && \
          rm -f "node-$VERSION.tar.gz" 2>/dev/null && \
          rm -rf "$NVM_DIR/$VERSION" 2>/dev/null)
      echo "Uninstalled node $VERSION"

      # Rm any aliases that point to uninstalled version.
      for A in `grep -l $VERSION $NVM_DIR/alias/*`
      do
        nvm unalias `basename $A`
      done

    ;;
    "deactivate" )
      if [[ $PATH == *$NVM_DIR/*/bin* ]]; then
        export PATH=${PATH%$NVM_DIR/*/bin*}${PATH#*$NVM_DIR/*/bin:}
        hash -r
        echo "$NVM_DIR/*/bin removed from \$PATH"
      else
        echo "Could not find $NVM_DIR/*/bin in \$PATH"
      fi
      if [[ $MANPATH == *$NVM_DIR/*/share/man* ]]; then
        export MANPATH=${MANPATH%$NVM_DIR/*/share/man*}${MANPATH#*$NVM_DIR/*/share/man:}
        echo "$NVM_DIR/*/share/man removed from \$MANPATH"
      else
        echo "Could not find $NVM_DIR/*/share/man in \$MANPATH"
      fi
    ;;
    "use" )
      if [ $# -ne 2 ]; then
        nvm help
        return
      fi
      VERSION=`nvm_version $2`
      if [ ! -d $NVM_DIR/$VERSION ]; then
        echo "$VERSION version is not installed yet"
        return;
      fi
      if [[ $PATH == *$NVM_DIR/*/bin* ]]; then
        PATH=${PATH%$NVM_DIR/*/bin*}$NVM_DIR/$VERSION/bin${PATH#*$NVM_DIR/*/bin}
      else
        PATH="$NVM_DIR/$VERSION/bin:$PATH"
      fi
      if [[ $MANPATH == *$NVM_DIR/*/share/man* ]]; then
        MANPATH=${MANPATH%$NVM_DIR/*/share/man*}$NVM_DIR/$VERSION/share/man${MANPATH#*$NVM_DIR/*/share/man}
      else
        MANPATH="$NVM_DIR/$VERSION/share/man:$MANPATH"
      fi
      export PATH
      hash -r
      export MANPATH
      export NVM_PATH="$NVM_DIR/$VERSION/lib/node"
      export NVM_BIN="$NVM_DIR/$VERSION/bin"
      echo "Now using node $VERSION"
    ;;
    "ls" | "list" )
      if [ $# -ne 1 ]; then
        nvm_version $2
        return
      fi
      nvm_version all
      echo -ne "current: \t"; nvm_version current
      nvm alias
    ;;
    "alias" )
      mkdir -p $NVM_DIR/alias
      if [ $# -le 2 ]; then
        (cd $NVM_DIR/alias && for ALIAS in `\ls $2* 2>/dev/null`; do
            DEST=`cat $ALIAS`
            VERSION=`nvm_version $DEST`
            if [ "$DEST" = "$VERSION" ]; then
                echo "$ALIAS -> $DEST"
            else
                echo "$ALIAS -> $DEST (-> $VERSION)"
            fi
        done)
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
        ROOT=`nvm use $VERSION && npm -g root`
        INSTALLS=`nvm use $VERSION > /dev/null && npm -g -p ll | grep "$ROOT\/[^/]\+$" | cut -d '/' -f 8 | cut -d ":" -f 2 | grep -v npm | tr "\n" " "`
        npm install -g $INSTALLS
    ;;
    "clear-cache" )
        rm -f $NVM_DIR/v* 2>/dev/null
        echo "Cache cleared."
    ;;
    "version" )
        nvm_version $2
    ;;
    "versions" )
      curl -s -o - http://nodejs.org/dist/ | grep -oE 'v[0-9]\.[0-9]\.[0-9]' | sort -u
    ;;
    * )
      nvm help
    ;;
  esac
}

nvm ls default >/dev/null 2>&1 && nvm use default >/dev/null
