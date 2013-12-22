#!/bin/bash

set -e

fatalExit (){
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
echo -e "\r=> Downloading... \c"

# Detect if curl or wget is installed to download NVM_SOURCE
if type curl > /dev/null 2>&1; then
  curl --silent "$NVM_SOURCE" -o "$NVM_DIR/nvm.sh" || fatalExit "Failed downloading $NVM_SOURCE";
elif type wget > /dev/null 2>&1; then 
  wget --quiet "$NVM_SOURCE" -O "$NVM_DIR/nvm.sh" || fatalExit "Failed downloading $NVM_SOURCE";
else
  fatalExit "Must have curl or wget to install nvm";
fi

echo "Downloaded"

echo

# Detect profile file if not specified as environment variable (eg: PROFILE=~/.myprofile).
if [ -z "$PROFILE" ]; then
  if [ -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
    PROFILE="$HOME/.profile"
  fi
fi

SOURCE_STR="[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"  # This loads NVM"

if [ -z "$PROFILE" ] || [ ! -f "$PROFILE" ] ; then
  if [ -z $PROFILE ]; then
    echo "=> Profile not found. Tried ~/.bash_profile ~/.zshrc and ~/.profile."
    echo "=> Create one of them and run this script again"
  else
    echo "=> Profile $PROFILE not found"
    echo "=> Create it (touch $PROFILE) and run this script again"
  fi
  echo "   OR"
  echo "=> Append the following line to the correct file yourself:"
  echo
  echo "   $SOURCE_STR"
  echo
else
  if ! grep -qc 'nvm.sh' $PROFILE; then
    echo "=> Appending source string to $PROFILE"
    echo "" >> "$PROFILE"
    echo $SOURCE_STR >> "$PROFILE"
  else
    echo "=> Source string already in $PROFILE"
  fi
fi

echo "=> Close and reopen your terminal to start using NVM"

