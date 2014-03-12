#!/bin/bash

function fatalExit (){
    echo "$@" && exit 1;
}

# an alternative URL that could be used: https://github.com/creationix/nvm/tarball/master
if [ "$NVM_SOURCE" = "" ]; then
    NVM_SOURCE="https://raw.github.com/creationix/nvm/master/nvm.sh"
fi

if [ "$NVM_DIR" = "" ]; then
    NVM_DIR="$HOME/.nvm"
fi

# Downloading to $NVM_DIR
mkdir -p "$NVM_DIR"
pushd "$NVM_DIR" > /dev/null
echo -ne "=> Downloading... "

# Detect if curl or wget is installed to download NVM_SOURCE
if type curl > /dev/null 2>&1; then
    curl --silent "$NVM_SOURCE" -o nvm.sh || fatalExit "Failed";
elif type wget > /dev/null 2>&1; then 
    wget --quiet "$NVM_SOURCE" -O nvm.sh || fatalExit "Failed";
else
    fatalExit "Must have curl or wget to install nvm";
fi

echo "Downloaded"
popd > /dev/null

# Detect profile file, .bash_profile has precedence over .profile
if [ ! -z "$1" ]; then
  PROFILE="$1"
else
  if [ -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.profile" ]; then
    PROFILE="$HOME/.profile"
  fi
fi

SOURCE_STR="[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # This loads NVM"

if [ -z "$PROFILE" ] || [ ! -f "$PROFILE" ] ; then
  if [ -z $PROFILE ]; then
    echo "=> Profile not found"
  else
    echo "=> Profile $PROFILE not found"
  fi
  echo "=> Append the following line to the correct file yourself"
  echo
  echo "\t$SOURCE_STR"
  echo
  echo "=> Close and reopen your terminal to start using NVM"
  exit
fi

if ! grep -qc 'nvm.sh' $PROFILE; then
  echo "=> Appending source string to $PROFILE"
  echo "" >> "$PROFILE"
  echo $SOURCE_STR >> "$PROFILE"
else
  echo "=> Source string already in $PROFILE"
fi

echo "=> Close and reopen your terminal to start using NVM"
