#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset -f nvm_ls_remote nvm_ls_remote_iojs
}

\. ../../../nvm.sh

OUTPUT="$(nvm_remote_versions stable 2>&1)"
EXPECTED_OUTPUT="Implicit aliases are not supported in nvm_remote_versions."
EXIT_CODE="$(nvm_remote_versions stable >/dev/null 2>&1; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "implicit alias 'stable' did not error out with correct message, got $OUTPUT"
[ "_$EXIT_CODE" = "_1" ] || die "implicit alias 'stable' did not exit with code 1, got $EXIT_CODE"

OUTPUT="$(nvm_remote_versions unstable 2>&1)"
EXPECTED_OUTPUT="Implicit aliases are not supported in nvm_remote_versions."
EXIT_CODE="$(nvm_remote_versions unstable >/dev/null 2>&1; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "implicit alias 'unstable' did not error out with correct message, got $OUTPUT"
[ "_$EXIT_CODE" = "_1" ] || die "implicit alias 'unstable' did not exit with code 1, got $EXIT_CODE"

nvm_ls_remote() {
  echo "N/A"
}
OUTPUT="$(nvm_remote_versions foo)"
EXIT_CODE="$(nvm_remote_versions foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_N/A" ] || die "nonexistent version did not report N/A"
[ "_$EXIT_CODE" = "_3" ] || die "nonexistent version did not exit with code 3, got $EXIT_CODE"

nvm_ls_remote_iojs() {
  echo "N/A"
}
OUTPUT="$(nvm_remote_versions iojs-foo)"
EXIT_CODE="$(nvm_remote_versions iojs-foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_N/A" ] || die "nonexistent version did not report N/A"
[ "_$EXIT_CODE" = "_3" ] || die "nonexistent version did not exit with code 3, got $EXIT_CODE"


nvm_ls_remote() {
  echo "test output"
  echo "more test output"
  echo "pattern received: _$1_"
}
nvm_ls_remote_iojs() {
  echo "test iojs output"
  echo "more iojs test output"
  echo "iojs pattern received: _$1_"
}

OUTPUT="$(nvm_remote_versions foo)"
EXIT_CODE="$(nvm_remote_versions foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_$(nvm_ls_remote foo)
$(nvm_ls_remote_iojs foo)" ] \
  || die "nvm_remote_versions foo did not return contents of nvm_ls_remote foo combined with nvm_ls_remote_iojs foo; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_versions foo did not exit with 0, got $EXIT_CODE"

OUTPUT="$(nvm_remote_versions node)"
EXIT_CODE="$(nvm_remote_versions node >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_$(nvm_ls_remote)" ] \
  || die "nvm_remote_versions node did not return contents of nvm_ls_remote; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_versions node did not exit with 0, got $EXIT_CODE"

OUTPUT="$(nvm_remote_versions iojs-foo)"
EXIT_CODE="$(nvm_remote_versions iojs-foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_$(nvm_ls_remote iojs-foo)
$(nvm_ls_remote_iojs iojs-foo)" ] \
  || die "nvm_remote_versions iojs-foo did not return contents of nvm_ls_remote iojs-foo combined with nvm_ls_remote_iojs iojs-foo; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_versions iojs-foo did not exit with 0, got $EXIT_CODE"

OUTPUT="$(nvm_remote_versions iojs)"
EXIT_CODE="$(nvm_remote_versions iojs >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_$(nvm_ls_remote_iojs)" ] \
  || die "nvm_remote_versions iojs did not return contents of nvm_ls_remote_iojs; got $OUTPUT"
[ "_$EXIT_CODE" = "_0" ] || die "nvm_remote_versions iojs did not exit with 0, got $EXIT_CODE"

cleanup
