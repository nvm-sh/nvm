#!/usr/bin/env bats

NVM_SRC_DIR="${BATS_TEST_DIRNAME}/../.."

setup() {
    echo 'setup' >&2
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
    mkdir src alias

    echo loopback > alias/loopback
    echo two > alias/one
    echo three > alias/two
    echo one > alias/three

    echo two > alias/four
}

teardown() {
    echo 'teardown' >&2
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
}

@test './Aliases/circular/nvm_resolve_alias' {
    load "${NVM_SRC_DIR}/nvm.sh"

    die () { echo $@ ; exit 1; }

    run nvm_resolve_alias loopback
    [ "$output" -eq "∞" ]

    run nvm alias loopback
    [ "$output" -eq "loopback -> loopback (-> ∞)" ]

    ALIAS="$(nvm_resolve_alias one)"
    [ "_$ALIAS" = "_∞" ]
    OUTPUT="$(nvm alias one)"
    EXPECTED_OUTPUT="one -> two (-> ∞)"
    [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ]

    ALIAS="$(nvm_resolve_alias two)"
    [ "_$ALIAS" = "_∞" ]
    OUTPUT="$(nvm alias two)"
    EXPECTED_OUTPUT="two -> three (-> ∞)"
    [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ]

    ALIAS="$(nvm_resolve_alias three)"
    [ "_$ALIAS" = "_∞" ]
    OUTPUT="$(nvm alias three)"
    EXPECTED_OUTPUT="three -> one (-> ∞)"
    [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ]

    ALIAS="$(nvm_resolve_alias four)"
    [ "_$ALIAS" = "_∞" ]
    OUTPUT="$(nvm alias four)"
    EXPECTED_OUTPUT="four -> two (-> ∞)"
    [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ]

    true
}

