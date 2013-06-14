#!/bin/bash

# an alternative URL that could be used: https://github.com/creationix/nvm/tarball/master
TARBALL_URL="https://api.github.com/repos/creationix/nvm/tarball"
NVM_TARGET="$HOME/.nvm"

if [ -d "$NVM_TARGET" ]; then
  echo "=> NVM is already installed in $NVM_TARGET, trying to update"
  rm -rf "$NVM_TARGET"
fi

# Downloading to $NVM_TARGET
mkdir "$NVM_TARGET"
pushd "$NVM_TARGET" > /dev/null
echo -ne "=> "
curl --silent -L "$TARBALL_URL" | tar -xz --strip-components=1 || exit 1
echo -n Downloaded
popd > /dev/null

echo

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

SOURCE_STR="[[ -s "$NVM_TARGET/nvm.sh" ]] && . "$NVM_TARGET/nvm.sh"  # This loads NVM"

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
