#!/usr/bin/env bats

load test_helper

NVM_SRC_DIR="${BATS_TEST_DIRNAME}/../.."
NVM_DIR="${BATS_TMPDIR}"
load "${NVM_SRC_DIR}/nvm.sh"

setup() {
    echo 'setup' >&2
    cd "${NVM_DIR}"
    rm -Rf src alias v*
    mkdir src alias
    for i in $(seq 1 10)
    do
        echo 0.0.$i > alias/test-stable-$i
        mkdir -p v0.0.$i
        echo 0.1.$i > alias/test-unstable-$i
        mkdir -p v0.1.$i
    done
}

teardown() {
    echo 'teardown' >&2
    cd "${NVM_DIR}"
    rm -Rf src alias v*
}

@test './Aliases/nvm_resolve_alias' {

    run nvm_resolve_alias
    [ "$status" -eq 1 ]

    for i in $(seq 1 10)
    do
        run nvm_resolve_alias test-stable-$i
        assert_success "v0.0.$i"

        run nvm_resolve_alias test-unstable-$i
        assert_success "v0.1.$i"
    done
    
    run nvm_resolve_alias nonexistent
    assert_failure 

    run nvm_resolve_alias stable
    assert_success "v0.0.10"

    run nvm_resolve_alias unstable
    assert_success "v0.1.10"
}

@test './Aliases/Running "nvm alias <aliasname>" should list but one alias.' {
##!/bin/sh
#
#. ../../../nvm.sh
#[ $(nvm alias test-stable-1 | wc -l) = '2' ]
}

@test './Aliases/Running "nvm alias" lists implicit aliases when they do not exist' {
##!/bin/sh
#
#. ../../../nvm.sh
#
#die () { echo $@ ; exit 1; }
#
#NVM_ALIAS_OUTPUT=$(nvm alias)
#
#EXPECTED_STABLE="$(nvm_print_implicit_alias local stable)"
#STABLE_VERSION="$(nvm_version "$EXPECTED_STABLE")"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e "^stable -> $EXPECTED_STABLE (-> $STABLE_VERSION) (default)$" \
#  || die "nvm alias did not contain the default local stable node version"
#
#EXPECTED_UNSTABLE="$(nvm_print_implicit_alias local unstable)"
#UNSTABLE_VERSION="$(nvm_version "$EXPECTED_UNSTABLE")"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e "^unstable -> $EXPECTED_UNSTABLE (-> $UNSTABLE_VERSION) (default)$" \
#  || die "nvm alias did not contain the default local unstable node version"
#
}

@test './Aliases/Running "nvm alias" lists manual aliases instead of implicit aliases when present' {
##!/bin/sh
#
#. ../../../nvm.sh
#
#die () { echo $@ ; cleanup ; exit 1; }
#cleanup () {
#  rm -rf ../../../alias/stable
#  rm -rf ../../../alias/unstable
#  rm -rf ../../../v0.8.1
#  rm -rf ../../../v0.9.1
#}
#
#mkdir ../../../v0.8.1
#mkdir ../../../v0.9.1
#
#EXPECTED_STABLE="$(nvm_print_implicit_alias local stable)"
#STABLE_VERSION="$(nvm_version "$EXPECTED_STABLE")"
#
#EXPECTED_UNSTABLE="$(nvm_print_implicit_alias local unstable)"
#UNSTABLE_VERSION="$(nvm_version "$EXPECTED_UNSTABLE")"
#
#[ "_$STABLE_VERSION" != "_$UNSTABLE_VERSION" ] \
#  || die "stable and unstable versions are the same!"
#
#nvm alias stable "$EXPECTED_UNSTABLE"
#nvm alias unstable "$EXPECTED_STABLE"
#
#NVM_ALIAS_OUTPUT=$(nvm alias)
#
#echo "$NVM_ALIAS_OUTPUT" | \grep -e "^stable -> $EXPECTED_UNSTABLE (-> $UNSTABLE_VERSION)$" \
#  || die "nvm alias did not contain the overridden 'stable' alias"
#
#echo "$NVM_ALIAS_OUTPUT" | \grep -e "^unstable -> $EXPECTED_STABLE (-> $STABLE_VERSION)$" \
#  || die "nvm alias did not contain the overridden 'unstable' alias"
#
#cleanup
#
}

@test './Aliases/Running "nvm alias" should list all aliases.' {
##!/bin/sh
#
#. ../../../nvm.sh
#
#die () { echo $@ ; exit 1; }
#
#NVM_ALIAS_OUTPUT=$(nvm alias)
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-1 -> 0.0.1 (-> v0.0.1)$' \
#  || die "did not find test-stable-1 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-2 -> 0.0.2 (-> v0.0.2)$' \
#  || die "did not find test-stable-2 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-3 -> 0.0.3 (-> v0.0.3)$' \
#  || die "did not find test-stable-3 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-4 -> 0.0.4 (-> v0.0.4)$' \
#  || die "did not find test-stable-4 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-5 -> 0.0.5 (-> v0.0.5)$' \
#  || die "did not find test-stable-5 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-6 -> 0.0.6 (-> v0.0.6)$' \
#  || die "did not find test-stable-6 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-7 -> 0.0.7 (-> v0.0.7)$' \
#  || die "did not find test-stable-7 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-8 -> 0.0.8 (-> v0.0.8)$' \
#  || die "did not find test-stable-8 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-9 -> 0.0.9 (-> v0.0.9)$' \
#  || die "did not find test-stable-9 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-stable-10 -> 0.0.10 (-> v0.0.10)$' \
#  || die "did not find test-stable-10 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-1 -> 0.1.1 (-> v0.1.1)$' \
#  || die "did not find test-unstable-1 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-2 -> 0.1.2 (-> v0.1.2)$' \
#  || die "did not find test-unstable-2 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-3 -> 0.1.3 (-> v0.1.3)$' \
#  || die "did not find test-unstable-3 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-4 -> 0.1.4 (-> v0.1.4)$' \
#  || die "did not find test-unstable-4 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-5 -> 0.1.5 (-> v0.1.5)$' \
#  || die "did not find test-unstable-5 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-6 -> 0.1.6 (-> v0.1.6)$' \
#  || die "did not find test-unstable-6 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-7 -> 0.1.7 (-> v0.1.7)$' \
#  || die "did not find test-unstable-7 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-8 -> 0.1.8 (-> v0.1.8)$' \
#  || die "did not find test-unstable-8 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-9 -> 0.1.9 (-> v0.1.9)$' \
#  || die "did not find test-unstable-9 alias"
#echo "$NVM_ALIAS_OUTPUT" | \grep -e '^test-unstable-10 -> 0.1.10 (-> v0.1.10)$' \
#  || die "did not find test-unstable-10 alias"
#
}

