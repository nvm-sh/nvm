# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

# Auto detect the NVM_DIR using magic bash 3.x stuff
export NVM_DIR=$(dirname ${BASH_ARGV[0]})

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
      echo "    nvm ls                  List versions currently installed"
      echo "    nvm deactivate          Undo effects of NVM on current shell"
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
      if (
        mkdir -p "$NVM_DIR/src" &&
        cd "$NVM_DIR/src" && \
        wget "http://nodejs.org/dist/node-$2.tar.gz" -N && \
        tar -xzf "node-$2.tar.gz" && \
        cd "node-$2" && \
        ./configure --prefix="$NVM_DIR/$2" && \
        make && \
        make install
        )
      then
        nvm use $2
        if ! which npm ; then
          echo "Installing npm..."
          curl http://npmjs.org/install.sh | sh
        fi
      else
        echo "nvm: install $2 failed!"
      fi
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
        nvm help
        return;
      fi
      for f in $NVM_DIR/v*; do
        if [[ $PATH == *$f/bin* ]]; then
          echo "v${f##*v} *"
        else
          echo "v${f##*v}"
        fi
      done
    ;;
    * )
      nvm help
    ;;
  esac
}
