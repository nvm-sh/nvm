#!/bin/sh

TEST_PWD=$(pwd)
TEST_DIR="$TEST_PWD/nvm_die_on_prefix_tmp"

\. ../../../nvm.sh

TEST_VERSION_DIR="${TEST_DIR}/version"

cleanup () {
  rm -rf "$TEST_DIR"
  alias nvm_has='\nvm_has'
  alias npm='\npm'
  unset -f nvm_has npm
}

die () {
  echo "$@";
  cleanup;
  exit 1;
}

[ ! -e "$TEST_DIR" ] && mkdir "$TEST_DIR"

OUTPUT="$(nvm_die_on_prefix 2>&1)"
EXPECTED_OUTPUT="First argument \"delete the prefix\" must be zero or one"
EXIT_CODE="$(nvm_die_on_prefix >/dev/null 2>&1; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix' did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
[ "_$EXIT_CODE" = "_1" ] || die "'nvm_die_on_prefix' did not exit with 1; got "$EXIT_CODE""

OUTPUT="$(nvm_die_on_prefix 2 2>&1)"
EXPECTED_OUTPUT="First argument \"delete the prefix\" must be zero or one"
EXIT_CODE="$(nvm_die_on_prefix 2 >/dev/null 2>&1; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 2' did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
[ "_$EXIT_CODE" = "_1" ] || die "'nvm_die_on_prefix' did not exit with 1; got "$EXIT_CODE""

OUTPUT="$(nvm_die_on_prefix 0 2>&1)"
EXPECTED_OUTPUT='Second argument "nvm command", and third argument "nvm version dir", must both be nonempty'
EXIT_CODE="$(nvm_die_on_prefix 0 >/dev/null 2>&1; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0' did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
[ "_$EXIT_CODE" = "_2" ] || die "'nvm_die_on_prefix 0' did not exit with 2; got '$EXIT_CODE'"

nvm_has() { return 1; } # ie, npm is not installed
OUTPUT="$(nvm_die_on_prefix 0 version_dir foo 2>&1)"
[ -z "$OUTPUT" ] || die "nvm_die_on_prefix was not a noop when nvm_has returns 1, got '$OUTPUT'"

nvm_has() { return 0; }

OUTPUT="$(nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" 2>&1)"
[ -z "$OUTPUT" ] || die "'nvm_die_on_prefix' was not a noop when prefix is good; got '$OUTPUT'"

mkdir -p "$(nvm_version_dir new)"
ln -s "$(nvm_version_dir new)" "$TEST_DIR/node"

npm() {
  local args
  args="$@"
  if [ "_$args" = "_config --loglevel=warn get prefix" ]; then
    echo "$TEST_DIR/node"
  fi
}

OUTPUT="$(nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" 2>&1)"
[ -z "$OUTPUT" ] || die "'nvm_die_on_prefix' was not a noop when directory is equivalent; got '$OUTPUT'"

OUTPUT="$(PREFIX=bar nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" 2>&1)"
EXPECTED_OUTPUT='nvm is not compatible with the "PREFIX" environment variable: currently set to "bar"
Run `unset PREFIX` to unset it.'
EXIT_CODE="$(export PREFIX=bar ; nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" >/dev/null 2>&1; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'PREFIX=bar nvm_die_on_prefix 0 foo' did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
[ "_$EXIT_CODE" = "_3" ] || die "'PREFIX=bar nvm_die_on_prefix 0 foo' did not exit with 3; got '$EXIT_CODE'"

OUTPUT="$(export NPM_CONFIG_PREFIX=bar ; nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" 2>&1)"
EXPECTED_OUTPUT='nvm is not compatible with the "NPM_CONFIG_PREFIX" environment variable: currently set to "bar"
Run `unset NPM_CONFIG_PREFIX` to unset it.'
EXIT_CODE="$(export NPM_CONFIG_PREFIX=bar ; nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" >/dev/null 2>&1; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'NPM_CONFIG_PREFIX=bar nvm_die_on_prefix 0 foo' did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
[ "_$EXIT_CODE" = "_4" ] || die "'NPM_CONFIG_PREFIX=bar nvm_die_on_prefix 0 foo' did not exit with 4; got '$EXIT_CODE'"

OUTPUT="$(export npm_CONFIG_PREFIX=bar ; nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" 2>&1)"
EXPECTED_OUTPUT='nvm is not compatible with the "npm_CONFIG_PREFIX" environment variable: currently set to "bar"
Run `unset npm_CONFIG_PREFIX` to unset it.'
EXIT_CODE="$(export npm_CONFIG_PREFIX=bar ; nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" >/dev/null 2>&1; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'npm_CONFIG_PREFIX=bar nvm_die_on_prefix 0 foo' did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
[ "_$EXIT_CODE" = "_4" ] || die "'npm_CONFIG_PREFIX=bar nvm_die_on_prefix 0 foo' did not exit with 4; got '$EXIT_CODE'"

OUTPUT="$(export FOO='This contains NPM_CONFIG_PREFIX' ; nvm_die_on_prefix 0 foo "$(nvm_version_dir new)" 2>&1)"
[ -z "$OUTPUT" ] || die "'nvm_die_on_prefix' was not a noop; got '$OUTPUT'"

# npmrc tests
(
  cd "${TEST_DIR}"
  touch package.json

  # project: prefix
  echo 'prefix=garbage' > .npmrc
  OUTPUT="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" 2>&1)"
  EXPECTED_OUTPUT="Your project npmrc file ($(nvm_sanitize_path "${TEST_DIR}")/.npmrc)
has a \`globalconfig\` and/or a \`prefix\` setting, which are incompatible with nvm.
Run \`foo\` to unset it."
  EXIT_CODE="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" >/dev/null 2>&1; echo $?)"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0 foo' with project .npmrc that has prefix did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
  [ "_$EXIT_CODE" = "_10" ] || die "'nvm_die_on_prefix 0 foo' with project .npmrc that has prefix did not exit with 10; got '$EXIT_CODE'"

  # project: globalconfig
  echo 'globalconfig=garbage' > .npmrc
  OUTPUT="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" 2>&1)"
  EXPECTED_OUTPUT="Your project npmrc file ($(nvm_sanitize_path "${TEST_DIR}")/.npmrc)
has a \`globalconfig\` and/or a \`prefix\` setting, which are incompatible with nvm.
Run \`foo\` to unset it."
  EXIT_CODE="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" >/dev/null 2>&1; echo $?)"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0 foo' with project .npmrc that has globalconfig did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
  [ "_$EXIT_CODE" = "_10" ] || die "'nvm_die_on_prefix 0 foo' with project .npmrc that has globalconfig did not exit with 10; got '$EXIT_CODE'"

  rm "${TEST_DIR}/.npmrc" || die '.npmrc could not be removed'

  mkdir -p "${TEST_VERSION_DIR}"
  GLOBAL_NPMRC="${TEST_VERSION_DIR}/etc/npmrc"
  mkdir -p "${TEST_VERSION_DIR}/etc"

  BUILTIN_NPMRC="${TEST_VERSION_DIR}/lib/node_modules/npm/npmrc"
  mkdir -p "${TEST_VERSION_DIR}/lib/node_modules/npm/"

  export HOME="${TEST_VERSION_DIR}"
  USER_NPMRC="${TEST_VERSION_DIR}/.npmrc"

  # global: prefix
  echo 'prefix=garbage' > "${GLOBAL_NPMRC}"
  OUTPUT="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" 2>&1)"
  EXPECTED_OUTPUT="Your global npmrc file ($(nvm_sanitize_path "${GLOBAL_NPMRC}"))
has a \`globalconfig\` and/or a \`prefix\` setting, which are incompatible with nvm.
Run \`foo\` to unset it."
  EXIT_CODE="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" >/dev/null 2>&1; echo $?)"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0 foo' with global npmrc that has prefix did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
  [ "_$EXIT_CODE" = "_10" ] || die "'nvm_die_on_prefix 0 foo' with global npmrc that has prefix did not exit with 10; got '$EXIT_CODE'"

  # global: globalconfig
  echo 'globalconfig=garbage' > "${GLOBAL_NPMRC}"
  OUTPUT="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" 2>&1)"
  EXPECTED_OUTPUT="Your global npmrc file ($(nvm_sanitize_path "${GLOBAL_NPMRC}"))
has a \`globalconfig\` and/or a \`prefix\` setting, which are incompatible with nvm.
Run \`foo\` to unset it."
  EXIT_CODE="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" >/dev/null 2>&1; echo $?)"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0 foo' with global npmrc that has globalconfig did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
  [ "_$EXIT_CODE" = "_10" ] || die "'nvm_die_on_prefix 0 foo' with global npmrc that has globalconfig did not exit with 10; got '$EXIT_CODE'"

  rm "${GLOBAL_NPMRC}" || die "${GLOBAL_NPMRC} could not be removed"

  # builtin: prefix
  echo 'prefix=garbage' > "${BUILTIN_NPMRC}"
  OUTPUT="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" 2>&1)"
  EXPECTED_OUTPUT="Your builtin npmrc file ($(nvm_sanitize_path "${BUILTIN_NPMRC}"))
has a \`globalconfig\` and/or a \`prefix\` setting, which are incompatible with nvm.
Run \`foo\` to unset it."
  EXIT_CODE="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" >/dev/null 2>&1; echo $?)"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0 foo' with builtin npmrc that has prefix did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
  [ "_$EXIT_CODE" = "_10" ] || die "'nvm_die_on_prefix 0 foo' with builtin npmrc that has prefix did not exit with 10; got '$EXIT_CODE'"

  # builtin: globalconfig
  echo 'globalconfig=garbage' > "${BUILTIN_NPMRC}"
  OUTPUT="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" 2>&1)"
  EXPECTED_OUTPUT="Your builtin npmrc file ($(nvm_sanitize_path "${BUILTIN_NPMRC}"))
has a \`globalconfig\` and/or a \`prefix\` setting, which are incompatible with nvm.
Run \`foo\` to unset it."
  EXIT_CODE="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" >/dev/null 2>&1; echo $?)"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0 foo' with builtin npmrc that has globalconfig did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
  [ "_$EXIT_CODE" = "_10" ] || die "'nvm_die_on_prefix 0 foo' with builtin npmrc that has globalconfig did not exit with 10; got '$EXIT_CODE'"

  rm "${BUILTIN_NPMRC}" || die "${BUILTIN_NPMRC} could not be removed"

  # user: prefix
  echo 'prefix=garbage' > "${USER_NPMRC}"
  OUTPUT="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" 2>&1)"
  EXPECTED_OUTPUT="Your user’s .npmrc file ($(nvm_sanitize_path "${USER_NPMRC}"))
has a \`globalconfig\` and/or a \`prefix\` setting, which are incompatible with nvm.
Run \`foo\` to unset it."
  EXIT_CODE="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" >/dev/null 2>&1; echo $?)"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0 foo' with user .npmrc that has prefix did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
  [ "_$EXIT_CODE" = "_10" ] || die "'nvm_die_on_prefix 0 foo' with user .npmrc that has prefix did not exit with 10; got '$EXIT_CODE'"

  # user: globalconfig
  echo 'globalconfig=garbage' > "${USER_NPMRC}"
  OUTPUT="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" 2>&1)"
  EXPECTED_OUTPUT="Your user’s .npmrc file ($(nvm_sanitize_path "${USER_NPMRC}"))
has a \`globalconfig\` and/or a \`prefix\` setting, which are incompatible with nvm.
Run \`foo\` to unset it."
  EXIT_CODE="$(nvm_die_on_prefix 0 foo "${TEST_VERSION_DIR}" >/dev/null 2>&1; echo $?)"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_die_on_prefix 0 foo' with user .npmrc that has globalconfig did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
  [ "_$EXIT_CODE" = "_10" ] || die "'nvm_die_on_prefix 0 foo' with user .npmrc that has globalconfig did not exit with 10; got '$EXIT_CODE'"
)

cleanup
