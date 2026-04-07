#!/bin/sh

die () { echo "$@" ; exit 1; }

if [ -n "${ZSH_VERSION-}" ]; then
  # these are set by omz: https://github.com/ohmyzsh/ohmyzsh/tree/1ac40cd4456230f09bf0258b173304929d118992/plugins/common-aliases
  alias -g R='| less -S'
  alias -g G='| less -S'
  # these are set by yadr: https://github.com/skwp/dotfiles/blob/5c487de9b81cd4265ecc9df74477e410ffbda6a1/zsh/zsh-aliases.zsh
  alias -g C='| wc -l'
  alias -g H='| head'
  alias -g L="| less"
  alias -g N="| /dev/null"
  alias -g S='| sort'
  alias -g G='| grep'
fi

OUTPUT=$(\. ../../nvm.sh || echo 'sourcing returned nonzero exit code')
UNEXPECTED_OUTPUT="sourcing returned nonzero exit code"
[ "_$OUTPUT" != "_$UNEXPECTED_OUTPUT" ] || die "Sourcing nvm.sh should not fail"

if [ -n "${ZSH_VERSION-}" ]; then
  unalias \R
  unalias \G
  unalias \C
  unalias \H
  unalias \L
  unalias \N
  unalias \S
fi
