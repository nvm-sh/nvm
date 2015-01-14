#!/bin/bash

set -e

nvm_has() {
  type "$1" > /dev/null 2>&1
}

if [ -z "$NVM_DIR" ]; then
  NVM_DIR="$HOME/.nvm"
fi

nvm_latest_version() {
  echo "v0.22.2"
}

#
# Outputs the location to NVM depending on:
# * The availability of $NVM_SOURCE
# * The method used ("script" or "git" in the script, defaults to "git")
# NVM_SOURCE always takes precedence
#
nvm_source() {
  local NVM_METHOD
  NVM_METHOD="$1"
  if [ -z "$NVM_SOURCE" ]; then
    local NVM_SOURCE
    if [ "_$NVM_METHOD" = "_script" ]; then
      NVM_SOURCE="https://raw.githubusercontent.com/creationix/nvm/$(nvm_latest_version)/nvm.sh"
    elif [ "_$NVM_METHOD" = "_script-nvm-exec" ]; then
      NVM_SOURCE="https://raw.githubusercontent.com/creationix/nvm/$(nvm_latest_version)/nvm-exec"
    elif [ "_$NVM_METHOD" = "_git" ] || [ -z "$NVM_METHOD" ]; then
      NVM_SOURCE="https://github.com/creationix/nvm.git"
    else
      echo >&2 "Unexpected value \"$NVM_METHOD\" for \$NVM_METHOD"
      return 1
    fi
  fi
  echo "$NVM_SOURCE"
  return 0
}

nvm_download() {
  if nvm_has "curl"; then
    curl $*
  elif nvm_has "wget"; then
    # Emulate curl with wget
    ARGS=$(echo "$*" | command sed -e 's/--progress-bar /--progress=bar /' \
                           -e 's/-L //' \
                           -e 's/-I /--server-response /' \
                           -e 's/-s /-q /' \
                           -e 's/-o /-O /' \
                           -e 's/-C - /-c /')
    wget $ARGS
  fi
}

install_nvm_from_git() {
  if [ -d "$NVM_DIR/.git" ]; then
    echo "=> nvm is already installed in $NVM_DIR, trying to update"
    printf "\r=> "
    cd "$NVM_DIR" && (command git fetch 2> /dev/null || {
      echo >&2 "Failed to update nvm, run 'git fetch' in $NVM_DIR yourself." && exit 1
    })
  else
    # Cloning to $NVM_DIR
    echo "=> Downloading nvm from git to '$NVM_DIR'"
    printf "\r=> "
    mkdir -p "$NVM_DIR"
    command git clone "$(nvm_source git)" "$NVM_DIR"
  fi
  cd "$NVM_DIR" && command git checkout --quiet $(nvm_latest_version) && command git branch --quiet -D master >/dev/null 2>&1
  return
}

install_nvm_as_script() {
  local NVM_SOURCE
  NVM_SOURCE=$(nvm_source script)
  local NVM_EXEC_SOURCE
  NVM_EXEC_SOURCE=$(nvm_source script-nvm-exec)

  # Downloading to $NVM_DIR
  mkdir -p "$NVM_DIR"
  if [ -d "$NVM_DIR/nvm.sh" ]; then
    echo "=> nvm is already installed in $NVM_DIR, trying to update"
  else
    echo "=> Downloading nvm as script to '$NVM_DIR'"
  fi
  nvm_download -s "$NVM_SOURCE" -o "$NVM_DIR/nvm.sh" || {
    echo >&2 "Failed to download '$NVM_SOURCE'"
    return 1
  }
  nvm_download -s "$NVM_EXEC_SOURCE" -o "$NVM_DIR/nvm-exec" || {
    echo >&2 "Failed to download '$NVM_EXEC_SOURCE'"
    return 2
  }
  chmod a+x "$NVM_DIR/nvm-exec" || {
    echo >&2 "Failed to mark '$NVM_DIR/nvm-exec' as executable"
    return 3
  }
}

#
# Detect profile file if not specified as environment variable
# (eg: PROFILE=~/.myprofile)
# The echo'ed path is guaranteed to be an existing file
# Otherwise, an empty string is returned
#
nvm_detect_profile() {
  if [ -f "$PROFILE" ]; then
    echo "$PROFILE"
  elif [ -f "$HOME/.bashrc" ]; then
    echo "$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    echo "$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    echo "$HOME/.zshrc"
  elif [ -f "$HOME/.profile" ]; then
    echo "$HOME/.profile"
  fi
}

nvm_do_install() {
  if [ -z "$METHOD" ]; then
    # Autodetect install method
    if nvm_has "git"; then
      install_nvm_from_git
    elif nvm_has "nvm_download"; then
      install_nvm_as_script
    else
      echo >&2 "You need git, curl, or wget to install nvm"
      exit 1
    fi
  elif [ "~$METHOD" = "~git" ]; then
    if ! nvm_has "git"; then
      echo >&2 "You need git to install nvm"
      exit 1
    fi
    install_nvm_from_git
  elif [ "~$METHOD" = "~script" ]; then
    if ! nvm_has "nvm_download"; then
      echo >&2 "You need curl or wget to install nvm"
      exit 1
    fi
    install_nvm_as_script
  fi

  echo

  local NVM_PROFILE
  NVM_PROFILE=$(nvm_detect_profile)

  SOURCE_STR="\nexport NVM_DIR=\"$NVM_DIR\"\n[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"  # This loads nvm"

  if [ -z "$NVM_PROFILE" ] ; then
    echo "=> Profile not found. Tried $NVM_PROFILE (as defined in \$PROFILE), ~/.bashrc, ~/.bash_profile, ~/.zshrc, and ~/.profile."
    echo "=> Create one of them and run this script again"
    echo "=> Create it (touch $NVM_PROFILE) and run this script again"
    echo "   OR"
    echo "=> Append the following lines to the correct file yourself:"
    printf "$SOURCE_STR"
    echo
  else
    if ! grep -qc 'nvm.sh' "$NVM_PROFILE"; then
      echo "=> Appending source string to $NVM_PROFILE"
      printf "$SOURCE_STR\n" >> "$NVM_PROFILE"
    else
      echo "=> Source string already in $NVM_PROFILE"
    fi
  fi

  echo "=> Close and reopen your terminal to start using nvm"
  nvm_reset
}

#
# Unsets the various functions defined
# during the execution of the install script
#
nvm_reset() {
  unset -f nvm_do_install nvm_has nvm_download install_nvm_as_script install_nvm_from_git nvm_reset nvm_detect_profile nvm_latest_version
}

[ "_$NVM_ENV" = "_testing" ] || nvm_do_install
