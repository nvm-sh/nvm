#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

EXIT_CODE=$(nvm_resolve_local_alias ; echo $?)
[ "_$EXIT_CODE" = "_1" ] || die "nvm_resolve_local_alias without an argument did not return 1; got $EXIT_CODE"

for i in $(seq 1 10)
  do
  STABLE_ALIAS="$(nvm_resolve_local_alias test-stable-$i)"
  [ "_$STABLE_ALIAS" = "_v0.0.$i" ] \
    || die "'nvm_resolve_local_alias test-stable-$i' was not v0.0.$i; got $STABLE_ALIAS"
  UNSTABLE_ALIAS="$(nvm_resolve_local_alias test-unstable-$i)"
  [ "_$UNSTABLE_ALIAS" = "_v0.1.$i" ] \
    || die "'nvm_resolve_local_alias test-unstable-$i' was not v0.1.$i; got $UNSTABLE_ALIAS"
done

OUTPUT="$(nvm_resolve_local_alias nonexistent)"
EXIT_CODE=$(nvm_resolve_local_alias nonexistent > /dev/null 2>&1 ; echo $?)
[ "_$EXIT_CODE" = "_2" ] || die "'nvm_resolve_local_alias nonexistent' did not return 2; got $EXIT_CODE"
[ "_$OUTPUT" = "_" ] || die "'nvm_resolve_local_alias nonexistent' did not have empty output; got $OUTPUT"

STABLE="$(nvm_resolve_local_alias stable)"
[ "_$STABLE" = "_v0.0.10" ] || die "'nvm_resolve_local_alias stable' was not v0.0.10; got $STABLE"

NODE="$(nvm_resolve_local_alias node)"
[ "_$NODE" = "_v0.0.10" ] || die "'nvm_resolve_local_alias node' was not v0.0.10; got $NODE"

UNSTABLE="$(nvm_resolve_local_alias unstable)"
[ "_$UNSTABLE" = "_v0.1.10" ] || die "'nvm_resolve_local_alias unstable' was not v0.1.10; got $UNSTABLE"

IOJS="$(nvm_resolve_local_alias iojs)"
[ "_$IOJS" = "_iojs-v0.2.10" ] || die "'nvm_resolve_local_alias iojs' was not iojs-v0.2.10; got $IOJS"
