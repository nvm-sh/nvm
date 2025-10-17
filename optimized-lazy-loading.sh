#!/bin/bash

echo "Creating optimized lazy loading configuration..."

cat > ~/.zshrc.optimized << 'EOF'
zmodload zsh/zprof

export PNPM_HOME="/Users/joseffsdev/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

lazy_nvm() {
  unset -f nvm node npm npx
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
  fi
  "$@"
}

lazy_python() {
  unset -f python python3 pip pip3
  if command -v python3 >/dev/null 2>&1; then
    alias python=python3
    alias pip=pip3
  fi
  "$@"
}

lazy_rbenv() {
  unset -f ruby gem bundle
  if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  fi
  "$@"
}

lazy_pyenv() {
  unset -f python python3 pip pip3
  if [ -d "$HOME/.pyenv" ]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
  fi
  "$@"
}

[ -s "$HOME/.nvm/nvm.sh" ] && {
  alias nvm='lazy_nvm nvm'
  alias node='lazy_nvm node'
  alias npm='lazy_nvm npm'
  alias npx='lazy_nvm npx'
}

command -v python3 >/dev/null 2>&1 && {
  alias python='lazy_python python'
  alias python3='lazy_python python3'
  alias pip='lazy_python pip'
  alias pip3='lazy_python pip3'
}

[ -d "$HOME/.rbenv" ] && {
  alias ruby='lazy_rbenv ruby'
  alias gem='lazy_rbenv gem'
  alias bundle='lazy_rbenv bundle'
}

[ -d "$HOME/.pyenv" ] && {
  alias python='lazy_pyenv python'
  alias python3='lazy_pyenv python3'
  alias pip='lazy_pyenv pip'
  alias pip3='lazy_pyenv pip3'
}

[ -s "$HOME/.nvm/nvm.sh" ] && {
  autoload -U add-zsh-hook
  load-nvmrc() {
    if [[ -f .nvmrc && -r .nvmrc ]]; then
      lazy_nvm nvm use
    fi
  }
  add-zsh-hook chpwd load-nvmrc
}

zprof
EOF

echo "Optimized lazy loading configuration created at ~/.zshrc.optimized"