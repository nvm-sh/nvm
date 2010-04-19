# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

nvm()
{
  START=`pwd`
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
      echo "    nvm help            (Show this message)"
      echo "    nvm install version (Download and install a released version)"
      echo "    nvm clone           (Clone and install HEAD version)"
      echo "    nvm update          (Pull and rebuild HEAD version)"
      echo "    nvm list            (Show all installed versions)"
      echo "    nvm use version     (Set this version in the PATH)"
      echo
      echo "Example:"
      echo "    nvm install v0.1.91"
      echo
    ;;
    "clone" )
      if [ $# -ne 1 ]; then
        nvm help
        return;
      fi
      mkdir -p "$NVM_DIR/src" && \
      cd "$NVM_DIR/src" && \
      git clone git://github.com/ry/node.git && \
      cd node && \
      ./configure --prefix="$NVM_DIR/HEAD" && \
      make && \
      make install && \
      nvm use HEAD
      cd $START
    ;;
    "update" )
      if [ $# -ne 1 ]; then
        nvm help
        return;
      fi
      cd "$NVM_DIR/src/node" && \
      git pull --rebase origin master
      ./configure && \
      make clean all && \
      make install && \
      nvm use HEAD
      cd $START
    ;;
    "install" )
      if [ $# -ne 2 ]; then
        nvm help
        return;
      fi
      mkdir -p "$NVM_DIR/src" && \
      cd "$NVM_DIR/src" && \
      wget "http://nodejs.org/dist/node-$2.tar.gz" -N && \
      tar -xzf "node-$2.tar.gz" && \
      cd "node-$2" && \
      ./configure --prefix="$NVM_DIR/$2" && \
      make && \
      make install && \
      nvm use $2
      cd $START
    ;;
    "use" )
      if [ $# -ne 2 ]; then
        nvm help
        return;
      fi
      if [[ $PATH == *$NVM_DIR/*/bin* ]]; then
        PATH=${PATH%$NVM_DIR/*/bin*}$NVM_DIR/$2/bin${PATH#*$NVM_DIR/*/bin}
      else
        PATH="$NVM_DIR/$2/bin:$PATH"
      fi
      export PATH
      echo "Now using node $2"
    ;;
    "list" )
      if [ $# -ne 1 ]; then
        nvm help
        return;
      fi
      # TODO: put a star by the current active one if possible
      ls "$NVM_DIR" | grep -v src | grep -v nvm.sh | grep -v README.markdown
    ;;
    * )
      nvm help
    ;;
  esac
}