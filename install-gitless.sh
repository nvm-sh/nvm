#!/bin/bash

set -e

fatalExit(){
  echo "$@" && exit 1;
}

if [ ! "$NVM_SOURCE" ]; then
  NVM_SOURCE="https://raw.github.com/creationix/nvm/master/nvm.sh"
fi

if [ ! "$NVM_DIR" ]; then
  NVM_DIR="$HOME/.nvm"
fi

# Downloading to $NVM_DIR
mkdir -p "$NVM_DIR"
echo -ne "\r=> Downloading... \c"
curl --silent "$NVM_SOURCE" -o "$NVM_DIR/nvm.sh" || fatalExit "Failed downloading $NVM_SOURCE"
echo "Downloaded"

echo

# Detect profile file if not specified as environment variable (eg: NVM_PROFILE=~/.myprofile).
if [ ! "$NVM_PROFILE" ]; then
  if [ -f "$HOME/.bash_profile" ]; then
    NVM_PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    NVM_PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
    NVM_PROFILE="$HOME/.profile"
  fi
fi

SOURCE_STR="[ -s $NVM_DIR/nvm.sh ] && . $NVM_DIR/nvm.sh  # This loads NVM"

if [ -z "$NVM_PROFILE" ] || [ ! -f "$NVM_PROFILE" ] ; then
  if [ -z $NVM_PROFILE ]; then
    echo "=> Profile not found. Tried ~/.bash_profile ~/.zshrc and ~/.profile."
    echo "=> Create one of them and run this script again"
  else
    echo "=> Profile $NVM_PROFILE not found"
    echo "=> Create it (touch $NVM_PROFILE) and run this script again"
  fi
  echo "   OR"
  echo "=> Append the following line to the correct file yourself:"
  echo
  echo "   $SOURCE_STR"
  echo
else
  if ! grep -qc 'nvm.sh' $NVM_PROFILE; then
    echo "=> Appending source string to $NVM_PROFILE"
    echo "" >> "$NVM_PROFILE"
    echo $SOURCE_STR >> "$NVM_PROFILE"
  else
    echo "=> Source string already in $NVM_PROFILE"
  fi
fi

echo
echo "=> Close and reopen your terminal afterwards to start using NVM"
