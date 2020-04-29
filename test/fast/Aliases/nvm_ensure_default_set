#!/bin/sh

\. ../../common.sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm alias default 0.1 >/dev/null || die "'nvm alias default 0.1' failed"

nvm_ensure_default_set 0.3 || die "'nvm_ensure_default_set' with an existing default alias exits 0"

nvm unalias default || die "'nvm unalias default' failed"

OUTPUT="$(nvm_ensure_default_set 0.2)"
EXPECTED_OUTPUT="Creating default alias: default -> 0.2 (-> iojs-v0.2.10)"
EXIT_CODE="$?"

[ "_$(echo "$OUTPUT" | strip_colors)" = "_$EXPECTED_OUTPUT" ] || die "'nvm_ensure_default_set 0.2' did not output '$EXPECTED_OUTPUT', got '$OUTPUT'"
[ "_$EXIT_CODE" = "_0" ] || die "'nvm_ensure_default_set 0.2' did not exit with 0, got $EXIT_CODE"
