#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset -f nvm_ls_remote nvm_ls_remote_iojs
}

\. ../../../nvm.sh

nvm_ls_remote() {
  echo "N/A"
}
OUTPUT="$(nvm_remote_version foo)"
EXIT_CODE="$(nvm_remote_version foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_N/A" ] || die "nonexistent version did not report N/A"
[ "_$EXIT_CODE" = "_3" ] || die "nonexistent version did not exit with code 3, got $EXIT_CODE"

nvm_ls_remote_iojs() {
  echo "N/A"
}
OUTPUT="$(nvm_remote_version iojs-foo)"
EXIT_CODE="$(nvm_remote_version iojs-foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_N/A" ] || die "nonexistent version did not report N/A"
[ "_$EXIT_CODE" = "_3" ] || die "nonexistent version did not exit with code 3, got $EXIT_CODE"


nvm_ls_remote() {
  if [ -z "$1" ] || ! nvm_is_iojs_version "$1"; then
    echo "test_output"
    echo "more_test_output"
    echo "pattern_received:_$1_"
  fi
}
nvm_ls_remote_iojs() {
  if [ -z "$1" ] || nvm_is_iojs_version "$1"; then
    echo "test_iojs_output"
    echo "more_iojs_test_output"
    echo "iojs_pattern_received:_$1_"
  fi
}
OUTPUT="$(nvm_remote_version foo)"
EXIT_CODE="$(nvm_remote_version foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_pattern_received:_foo_" ] \
  || die "nvm_remote_version foo did not return last line only of nvm_ls_remote foo; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_version foo did not exit with 0, got $EXIT_CODE"

OUTPUT="$(nvm_remote_version iojs-foo)"
EXIT_CODE="$(nvm_remote_version iojs-foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_iojs_pattern_received:_iojs-foo_" ] \
  || die "nvm_remote_version iojs-foo did not return last line only of nvm_ls_remote_iojs foo; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_version iojs-foo did not exit with 0, got $EXIT_CODE"

OUTPUT="$(nvm_remote_version iojs)"
EXIT_CODE="$(nvm_remote_version iojs >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_iojs_pattern_received:__" ] \
  || die "nvm_remote_version iojs did not return last line only of nvm_ls_remote_iojs; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_version iojs did not exit with 0, got $EXIT_CODE"

OUTPUT="$(nvm_remote_version stable)"
EXIT_CODE="$(nvm_remote_version stable >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_$(nvm_ls_remote stable)" ] \
  || die "nvm_remote_version stable did not return contents of nvm_ls_remote stable; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_version stable did not exit with 0, got $EXIT_CODE"

OUTPUT="$(nvm_remote_version unstable)"
EXIT_CODE="$(nvm_remote_version unstable >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_$(nvm_ls_remote unstable)" ] \
  || die "nvm_remote_version unstable did not return contents of nvm_ls_remote unstable; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_version unstable did not exit with 0, got $EXIT_CODE"

OUTPUT="$(nvm_remote_version node)"
EXIT_CODE="$(nvm_remote_version node >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_$(nvm_ls_remote node)" ] \
  || die "nvm_remote_version node did not return contents of nvm_ls_remote node; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_version node did not exit with 0, got $EXIT_CODE"

cleanup
