#!/usr/bin/env bash

# bash completion for Node Version Manager (NVM)

__nvm_generate_completion()
{
  declare current_word
  current_word="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$1" -- "$current_word"))
  return 0
}

__nvm_commands ()
{
  declare current_word
  declare command

  current_word="${COMP_WORDS[COMP_CWORD]}"

  COMMANDS='
    help install uninstall use run exec
    alias unalias reinstall-packages
    current list ls list-remote ls-remote
    clear-cache deactivate unload
    version which'

    if [ ${#COMP_WORDS[@]} == 4 ]; then

      command="${COMP_WORDS[COMP_CWORD-2]}"
      case "${command}" in
      alias)  __nvm_installed_nodes ;;
      esac

    else

      case "${current_word}" in
      -*)     __nvm_options ;;
      *)      __nvm_generate_completion "$COMMANDS" ;;
      esac

    fi
}

__nvm_options ()
{
  OPTIONS=''
  __nvm_generate_completion "$OPTIONS"
}

__nvm_installed_nodes ()
{
  __nvm_generate_completion "$(nvm_ls) $(__nvm_aliases)"
}

__nvm_aliases ()
{
  declare aliases
  aliases=""
  if [ -d "$NVM_DIR/alias" ]; then
    aliases="$(cd "$NVM_DIR/alias" && command find "$PWD" -type f | command sed "s:$PWD/::")"
  fi
  echo "${aliases} node stable unstable iojs"
}

__nvm_alias ()
{
  __nvm_generate_completion "$(__nvm_aliases)"
}

__nvm ()
{
  declare previous_word
  previous_word="${COMP_WORDS[COMP_CWORD-1]}"

  case "$previous_word" in
  use|run|exec|ls|list|uninstall) __nvm_installed_nodes ;;
  alias|unalias)  __nvm_alias ;;
  *)              __nvm_commands ;;
  esac

  return 0
}

# complete is a bash builtin, but recent versions of ZSH come with a function
# called bashcompinit that will create a complete in ZSH. If the user is in
# ZSH, load and run bashcompinit before calling the complete function.
if [[ -n ${ZSH_VERSION-} ]]; then
  autoload -U +X bashcompinit && bashcompinit
fi

complete -o default -o nospace -F __nvm nvm

