#!/bin/bash

set -e

has() {
  type "$1" > /dev/null 2>&1
  return $?
}

if [ -z "$NVM_DIR" ]; then
  NVM_DIR="$HOME/.nvm"
fi

download_file() {
  # download_file source destination
  if has "curl"; then
    curl --silent "$1" -o "$2"
  elif has "wget"; then
    wget --quiet "$1" -O "$2"
  else
    return 1
  fi
}

install_from_git() {
  if [ -z "$NVM_SOURCE" ]; then
    NVM_SOURCE="https://github.com/creationix/nvm.git"
  fi

  if [ -d "$NVM_DIR/.git" ]; then
    echo "=> NVM is already installed in $NVM_DIR, trying to update"
    echo -e "\r=> \c"
    cd "$NVM_DIR" && git pull 2> /dev/null || {
      echo >&2 "Failed to update nvm, run 'git pull' in $NVM_DIR yourself.."
    }
  else
    # Cloning to $NVM_DIR
    mkdir -p "$NVM_DIR"
    git clone "$NVM_SOURCE" "$NVM_DIR"
  fi
}

install_as_script() {
  if [ -z "$NVM_SOURCE" ]; then
    NVM_SOURCE="https://raw.github.com/creationix/nvm/master/nvm.sh"
  fi

  # Downloading to $NVM_DIR
  mkdir -p "$NVM_DIR"
  if [ -d "$NVM_DIR/nvm.sh" ]; then
    echo "=> NVM is already installed in $NVM_DIR, trying to update"
  else
    echo "=> Downloading NVM to '$NVM_DIR'"
  fi
  download_file "$NVM_SOURCE" "$NVM_DIR/nvm.sh" || {
    echo >&2 "Failed.."
    return 1
  }
}

if has "git"; then
 install_from_git
else
  install_as_script || {
    echo >&2 -e "You need git, curl or wget to install NVM"
    exit 1
  }
fi

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

