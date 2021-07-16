#!/bin/sh

cleanup () {
  rm tmp/node
  rmdir tmp
  rm tmp2/node
  rmdir tmp2
}
die () { echo "$@" ; cleanup; exit 1; }

\. ../../../nvm.sh

mkdir -p tmp
touch tmp/node
mkdir -p tmp2
touch tmp2/node

[ "$(nvm_tree_contains_path 2>&1)" = "both the tree and the node path are required" ] || die 'incorrect error message with no args'
[ "$(nvm_tree_contains_path > /dev/null 2>&1 ; echo $?)" = "2" ] || die 'incorrect error code with no args'
[ "$(nvm_tree_contains_path tmp 2>&1)" = "both the tree and the node path are required" ] || die 'incorrect error message with one arg'
[ "$(nvm_tree_contains_path > /dev/null 2>&1 ; echo $?)" = "2" ] || die 'incorrect error code with one arg'

nvm_tree_contains_path tmp tmp/node || die '"tmp" should contain "tmp/node"'

nvm_tree_contains_path tmp tmp2/node && die '"tmp" should not contain "tmp2/node"'

nvm_tree_contains_path tmp2 tmp2/node || die '"tmp2" should contain "tmp2/node"'

nvm_tree_contains_path tmp2 tmp/node && die '"tmp2" should not contain "tmp/node"'

cleanup
