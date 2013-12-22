#!/bin/bash

set -e

NVM_DIR="$HOME/.nvm"

if ! hash git 2>/dev/null; then
  echo >&2 "You need to install git - visit http://git-scm.com/downloads"
  echo >&2 "or, use install-gitless.sh instead."
  exit 1
fi

if [ -d "$NVM_DIR" ]; then
  echo "=> NVM is already installed in $NVM_DIR, trying to update"
  echo -ne "\r=> "
  cd $NVM_DIR && git pull
else
  # Cloning to $NVM_DIR
  git clone https://github.com/creationix/nvm.git $NVM_DIR  
fi

echo

# Detect profile file, .bash_profile has precedence over .profile
if [ ! -z "$1" ]; then
  PROFILE="$1"
else
  if [ -f "$HOME/.bash_profile" ]; then
	PROFILE="$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
  	PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
	PROFILE="$HOME/.profile"
  fi
fi

SOURCE_STR="[[ -s \$HOME/.nvm/nvm.sh ]] && . \$HOME/.nvm/nvm.sh  # This loads NVM"

if [ -z "$PROFILE" ] || [ ! -f "$PROFILE" ] ; then
  if [ -z $PROFILE ]; then
	echo "=> Profile not found. Tried $HOME/.bash_profile and $HOME/.profile"
  else
	echo "=> Profile $PROFILE not found"
  fi
  echo "=> Run this script again after running the following:"
  echo
  echo "\ttouch $HOME/.profile"
  echo
  echo "-- OR --"
  echo
  echo "=> Append the following line to the correct file yourself"
  echo
  echo "\t$SOURCE_STR"
  echo
  echo "=> Close and reopen your terminal afterwards to start using NVM"
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

