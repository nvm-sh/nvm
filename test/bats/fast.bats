#!/usr/bin/env bats

NVM_SRC_DIR="${BATS_TEST_DIRNAME}/../.."
load "${NVM_SRC_DIR}/nvm.sh"

setup() {
    echo 'setup' >&2
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
    mkdir src alias
}

teardown() {
    echo 'teardown' >&2
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
}

@test "'nvm' command defined in environment" {
    run nvm
    [ "$status" -eq 0 ]
}

@test "Running 'nvm alias' should create a file in the alias directory." {
    run nvm alias test v0.1.2
    [ "$status" -eq 0 ]
    result=$(cat "alias/test")
    [ "$result" = "v0.1.2" ]
}

