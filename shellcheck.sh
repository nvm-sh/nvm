#!/usr/bin/env bash

for shell in bash sh dash ksh
do
  shellcheck -s "${shell}" nvm.sh
done

for bash_script in install.sh
do
  shellcheck -s bash "${bash_script}"
done
