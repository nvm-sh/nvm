# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

# Auto detect the NVM_DIR using magic bash 3.x stuff
export NVM_DIR=$(dirname ${BASH_ARGV[0]})

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
    if [[ "$PATTERN" == v*.*.* ]]; then
        VERSION="$PATTERN"
    fi
    # The default version is the current one
    if [ ! "$PATTERN" -o "$PATTERN" = 'current' ]; then
        VERSION=`node -v 2>/dev/null`
    fi
    if [ "$PATTERN" = 'stable' ]; then
        PATTERN='*.*[02468].'
    fi
    if [ "$PATTERN" = 'latest' ]; then
        PATTERN='*.*.'
    fi
    if [ "$PATTERN" = 'all' ]; then
        (cd $NVM_DIR; ls -dG v* 2>/dev/null || echo "N/A")
        return
    fi
    if [ ! "$VERSION" ]; then
        VERSION=`(cd $NVM_DIR; ls -d v${PATTERN}* 2>/dev/null) | sort -t. -k 2,1n -k 2,2n -k 3,3n | tail -n1`
    fi
    if [ ! "$VERSION" ]; then
        echo "N/A"
        return -1
    elif [ -e "$NVM_DIR/$VERSION" ]; then
        (cd $NVM_DIR; ls -dG "$VERSION")
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
      echo "    nvm use <version>           Modify PATH to use <version>"
      echo "    nvm ls                      List versions (installed versions are blue)"
      echo "    nvm ls <version>            List versions matching a given description"
      echo "    nvm deactivate              Undo effects of NVM on current shell"
      echo "    nvm sync                    Update the local cache of available versions"
      echo "    nvm alias [<pattern>]       Show all aliases beginning with <pattern>"
      echo "    nvm alias <name> <version>  Set an alias named <name> pointing to <version>"
      echo
      echo "Example:"
      echo "    nvm install v0.2.5          Install a specific version number"
      echo "    nvm use stable              Use the stable release"
      echo "    nvm install latest          Install the latest, possibly unstable version"
      echo "    nvm use 0.3                 Use the latest available 0.3.x release"
      echo "    nvm alias default v0.3.6    Set v0.3.6 as the default" 
      echo
    ;;
    "install" )
      if [ $# -ne 2 ]; then
        nvm help
        return;
      fi
      VERSION=`nvm_version $2`
      START=`pwd`
      mkdir -p "$NVM_DIR/src" && \
      rm -f "$NVM_DIR/$2" && \
      cd "$NVM_DIR/src" && \
      wget "http://nodejs.org/dist/node-$VERSION.tar.gz" -N && \
      tar -xzf "node-$VERSION.tar.gz" && \
      cd "node-$VERSION" && \
      ./configure --prefix="$NVM_DIR/$VERSION" && \
      make && \
      make install && \
      nvm use $VERSION
      if ! which npm ; then
        echo "Installing npm..."
        curl http://npmjs.org/install.sh | sh
      fi
      cd $START
    ;;
    "deactivate" )
      if [[ $PATH == *$NVM_DIR/*/bin* ]]; then
        export PATH=${PATH%$NVM_DIR/*/bin*}${PATH#*$NVM_DIR/*/bin:}
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
      export MANPATH
      export NVM_PATH="$NVM_DIR/$VERSION/lib/node"
      export NVM_BIN="$NVM_DIR/$VERSION/bin"
      echo "Now using node $VERSION"
    ;;
    "ls" )
      if [ $# -ne 1 ]; then
        nvm_version $2
        return
      fi
      nvm_version all
      for P in {stable,latest,current}; do
          echo -ne "$P: \t"; nvm_version $P
      done
      nvm alias
      echo "# use 'nvm sync' to update from nodejs.org"
    ;;
    "alias" )
      if [ $# -le 2 ]; then
        (cd $NVM_DIR/alias; for ALIAS in `ls $2* 2>/dev/null`; do
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
          echo "! WARNING: Moving target. Aliases to implicit versions may change without warning."
      else
        echo "$2 -> $3"
      fi
    ;;
    "sync" )
        LATEST=`nvm_version latest`
        STABLE=`nvm_version stable`
        (cd $NVM_DIR
        rm -f v* 2>/dev/null
        echo -n "# syncing with nodejs.org..."
        for VER in `curl -s http://nodejs.org/dist/ | grep 'node-v.*\.tar\.gz' | sed -e 's/.*node-//' -e 's/\.tar\.gz.*//'`; do
            touch $VER
        done
        echo " done."
        )
        [ "$STABLE" = `nvm_version stable` ] || echo "NEW stable: `nvm_version stable`"
        [ "$LATEST" = `nvm_version latest` ] || echo "NEW latest: `nvm_version latest`"
    ;;
    "clear-cache" )
        rm -f $NVM_DIR/v*
        echo "Cache cleared."
    ;;
    "version" )
        nvm_version $2
    ;;
    * )
      nvm help
    ;;
  esac
}

nvm ls default >/dev/null 2>&1 && nvm use default >/dev/null
