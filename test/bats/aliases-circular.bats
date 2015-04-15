#!/usr/bin/env bats

load test_helper

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
    assert_success "∞"
    run nvm alias loopback
    assert_success "loopback -> loopback (-> ∞)"

    run nvm_resolve_alias one
    assert_success "∞"
    run nvm alias one
    assert_success "one -> two (-> ∞)"

    run nvm_resolve_alias two
    assert_success "∞"
    run nvm alias two
    assert_success "two -> three (-> ∞)"

    run nvm_resolve_alias three
    assert_success "∞"
    run nvm alias three
    assert_success "three -> one (-> ∞)"

    run nvm_resolve_alias four
    assert_success "∞"
    run nvm alias four
    assert_success "four -> two (-> ∞)"
}
