#!/bin/sh

TEST_PWD=$(pwd)
TEST_DIR="$TEST_PWD/nvm_ls_current_tmp"

cleanup() { rm -rf "$TEST_DIR"; unset -f return_zero; alias node='node' ; unalias node; }
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

return_zero () { return 0; }

if nvm_has_system_node || nvm_has_system_iojs; then
  EXPECTED_SYSTEM_NODE="system"
else
  EXPECTED_SYSTEM_NODE="none"
fi
[ "_$(nvm deactivate > /dev/null 2>&1 ; nvm_ls_current)" = "_$EXPECTED_SYSTEM_NODE" ] || die "when deactivated, did not return $EXPECTED_SYSTEM_NODE"

rm -rf "$TEST_DIR"
mkdir "$TEST_DIR"
# Ensure that the system version of which is used, not node_modules/.bin/which
ln -s "$(PATH=$(echo $PATH | tr ":" "\n" | grep -v "node_modules/.bin" | tr "\n" ":") command which which)" "$TEST_DIR/which"
ln -s "$(command which dirname)" "$TEST_DIR/dirname"
ln -s "$(command which printf)" "$TEST_DIR/printf"

[ "$(PATH="$TEST_DIR" nvm_ls_current)" = "none" ] || die 'when node not installed, nvm_ls_current did not return "none"'
[ "@$(PATH="$TEST_DIR" nvm_ls_current 2> /dev/stdout 1> /dev/null)@" = "@@" ] || die 'when node not installed, nvm_ls_current returned error output'

echo "#!/bin/bash" > "$TEST_DIR/node"
echo "echo 'VERSION FOO!'" >> "$TEST_DIR/node"
chmod a+x "$TEST_DIR/node"

[ "$(PATH="$TEST_DIR" nvm_ls_current)" = "VERSION FOO!" ] || die 'when activated, did not return nvm node version'

alias node='node --harmony'
[ "$(PATH="$TEST_DIR" nvm_ls_current)" = "VERSION FOO!" ] || die 'when activated and node aliased, did not return nvm node version'

cleanup
