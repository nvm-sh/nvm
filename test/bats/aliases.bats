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
    for i in 1 2 3 4 5 6 7 8 9 10
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
        assert_success "v0.0.$i" "nvm_resolve_alias test-stable-$i"

        run nvm_resolve_alias test-unstable-$i
        assert_success "v0.1.$i" "nvm_resolve_alias test-unstable-$i"
    done
    
    run nvm_resolve_alias nonexistent
    assert_failure 

    run nvm_resolve_alias stable
    assert_success "v0.0.10"  "'nvm_resolve_alias stable' was not v0.0.10"

    run nvm_resolve_alias unstable
    assert_success "v0.1.10"  "'nvm_resolve_alias unstable' was not v0.1.10"
}

@test './Aliases/Running "nvm alias <aliasname>" should list but one alias.' {
    run nvm alias test-stable-1
    assert_success
    
    local num_lines="${#lines[@]}"
    assert_equal $num_lines 2
}

@test './Aliases/Running "nvm alias" lists implicit aliases when they do not exist' {
    run nvm alias

    assert_line 20 "stable -> 0.0 (-> v0.0.10) (default)"  "nvm alias did not contain the default local stable node version"
    assert_line 21 "unstable -> 0.1 (-> v0.1.10) (default)" "nvm alias did not contain the default local unstable node version"
}

@test './Aliases/Running "nvm alias" lists manual aliases instead of implicit aliases when present' {
    mkdir v0.8.1
    mkdir v0.9.1
    
    stable="$(nvm_print_implicit_alias local stable)"
    unstable="$(nvm_print_implicit_alias local unstable)"
   
    assert_unequal $stable $unstable "stable and unstable versions are the same!"

    run nvm alias stable $unstable
    run nvm alias unstable $stable

    run nvm alias

    assert_line  0 "stable -> 0.9 (-> v0.9.1)"    "nvm alias did not contain the overridden 'stable' alias"
    assert_line 21 "unstable -> 0.8 (-> v0.8.1)"  "nvm alias did not contain the overridden 'unstable' alias"
}

