# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

# Auto detect the NVM_DIR using magic bash 3.x stuff
export NVM_DIR=$(dirname ${BASH_ARGV[0]})

# Expand a version using the version cache
version()
{
    PATTERN=$1
    VERSION=''
    # If it looks like an explicit version, don't do anything funny
    if [[ $PATTERN == v*.*.* ]]; then
        VERSION=$PATTERN
    fi
    # The default version is the current one
    if [ ! $PATTERN -o $PATTERN = 'current' ]; then
        VERSION=`node -v 2>/dev/null`
    fi
    if [ $PATTERN = 'stable' ]; then
        PATTERN='*.*[02468].'
    fi
    if [ $PATTERN = 'latest' ]; then
        PATTERN='*.*.'
    fi
    if [ $PATTERN = 'all' ]; then
        (cd $NVM_DIR; ls -dG v* 2>/dev/null || echo "N/A")
        return
    fi
    if [ ! "$VERSION" ]; then
        VERSION=`(cd $NVM_DIR; ls -d v${PATTERN}* 2>/dev/null) | sort -t. -k 2,1n -k 2,2n -k 3,3n | tail -n1`
    fi
    if [ ! "$VERSION" ]; then
        echo "N/A"
    elif [ -e "$NVM_DIR/$VERSION" ]; then
        (cd $NVM_DIR; ls -dG $VERSION)
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
      echo "    nvm help                Show this message"
      echo "    nvm install <version>   Download and install a <version>"
      echo "    nvm use <version>       Modify PATH to use <version>"
      echo "    nvm ls                  List versions (installed versions are blue)"
      echo "    nvm ls <version>        List versions matching a given description"
      echo "    nvm deactivate          Undo effects of NVM on current shell"
      echo "    nvm sync                Update the local cache of available versions"
      echo
      echo "Example:"
      echo "    nvm install v0.2.5"
      echo "    nvm use v0.2.5"
      echo
    ;;
    "install" )
      if [ $# -ne 2 ]; then
        nvm help
        return;
      fi
      START=`pwd`
      mkdir -p "$NVM_DIR/src" && \
      rm -f "$NVM_DIR/$2" && \
      cd "$NVM_DIR/src" && \
      wget "http://nodejs.org/dist/node-$2.tar.gz" -N && \
      tar -xzf "node-$2.tar.gz" && \
      cd "node-$2" && \
      ./configure --prefix="$NVM_DIR/$2" && \
      make && \
      make install && \
      nvm use $2
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
      if [ ! -d $NVM_DIR/$2 ]; then
        echo "$2 version is not installed yet"
        return;
      fi
      if [[ $PATH == *$NVM_DIR/*/bin* ]]; then
        PATH=${PATH%$NVM_DIR/*/bin*}$NVM_DIR/$2/bin${PATH#*$NVM_DIR/*/bin}
      else
        PATH="$NVM_DIR/$2/bin:$PATH"
      fi
      if [[ $MANPATH == *$NVM_DIR/*/share/man* ]]; then
        MANPATH=${MANPATH%$NVM_DIR/*/share/man*}$NVM_DIR/$2/share/man${MANPATH#*$NVM_DIR/*/share/man}
      else
        MANPATH="$NVM_DIR/$2/share/man:$MANPATH"
      fi
      export PATH
      export MANPATH
      export NVM_PATH="$NVM_DIR/$2/lib/node"
      export NVM_BIN="$NVM_DIR/$2/bin"
      echo "Now using node $2"
    ;;
    "ls" )
      if [ $# -ne 1 ]; then
        version $2
        return;
      fi
      version all
      for P in {stable,latest,current}; do
          echo -ne "$P: \t"; version $P
      done
      echo "# use 'nvm sync' to update from nodejs.org"
    ;;
    "sync" )
        (cd $NVM_DIR
        rm -f v* 2>/dev/null
        echo -n "Syncing with nodejs.org..."
        for VER in `curl -s http://nodejs.org/dist/ | grep 'node-v.*\.tar\.gz' | sed -e 's/.*node-//' -e 's/\.tar\.gz.*//'`
            do touch $VER
        done
        echo " done."
        )
    ;;
    "clear-cache" )
        rm -f $NVM_DIR/v*
        echo "Cache cleared."
    ;;
    "version" )
        version $2
    ;;
    * )
      nvm help
    ;;
  esac
}
