function nvm --description "Node version manager" -a nvm_command nvm_command_arg1
  set nvm_dir ~/.nvm
  set nvm_ $nvm_dir/nvm

  # This sets some environment vars that we need to set too
  if test "$nvm_command" = "use"
    eval $nvm_ use --print-paths $nvm_command_arg1 | sed -re "s|^(\w+=)|set -x \1|g" -e "s|[=:]| |g" | grep "set -x"  | .
  else
    # Make sure we can use node
    if test ! (which node)
      # Have we installed node at all ?
      if eval $nvm_ ls | grep "N/A" > /dev/null
        echo "No node installation found, installing stable"
        eval $nvm_ install stable
      end
      # Make sure we have a default picked
      if eval $nvm_ ls default | grep "N/A"
        eval $nvm_ alias default stable
      end
      nvm use default
    end
    eval $nvm_ $argv
  end
end
