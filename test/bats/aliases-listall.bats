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

@test './Aliases/Running "nvm alias" should list all aliases.' {
    run nvm alias
    
    assert_line  0 'test-stable-1 -> 0.0.1 (-> v0.0.1)'      "did not find test-stable-1 alias"
    assert_line  1 'test-stable-10 -> 0.0.10 (-> v0.0.10)'   "did not find test-stable-10 alias"
    assert_line  2 'test-stable-2 -> 0.0.2 (-> v0.0.2)'      "did not find test-stable-2 alias"
    assert_line  3 'test-stable-3 -> 0.0.3 (-> v0.0.3)'      "did not find test-stable-3 alias"
    assert_line  4 'test-stable-4 -> 0.0.4 (-> v0.0.4)'      "did not find test-stable-4 alias"
    assert_line  5 'test-stable-5 -> 0.0.5 (-> v0.0.5)'      "did not find test-stable-5 alias"
    assert_line  6 'test-stable-6 -> 0.0.6 (-> v0.0.6)'      "did not find test-stable-6 alias"
    assert_line  7 'test-stable-7 -> 0.0.7 (-> v0.0.7)'      "did not find test-stable-7 alias"
    assert_line  8 'test-stable-8 -> 0.0.8 (-> v0.0.8)'      "did not find test-stable-8 alias"
    assert_line  9 'test-stable-9 -> 0.0.9 (-> v0.0.9)'      "did not find test-stable-9 alias"
    assert_line 10 'test-unstable-1 -> 0.1.1 (-> v0.1.1)'    "did not find test-unstable-1 alias"
    assert_line 11 'test-unstable-10 -> 0.1.10 (-> v0.1.10)' "did not find test-unstable-10 alias"
    assert_line 12 'test-unstable-2 -> 0.1.2 (-> v0.1.2)'    "did not find test-unstable-2 alias"
    assert_line 13 'test-unstable-3 -> 0.1.3 (-> v0.1.3)'    "did not find test-unstable-3 alias"
    assert_line 14 'test-unstable-4 -> 0.1.4 (-> v0.1.4)'    "did not find test-unstable-4 alias"
    assert_line 15 'test-unstable-5 -> 0.1.5 (-> v0.1.5)'    "did not find test-unstable-5 alias"
    assert_line 16 'test-unstable-6 -> 0.1.6 (-> v0.1.6)'    "did not find test-unstable-6 alias"
    assert_line 17 'test-unstable-7 -> 0.1.7 (-> v0.1.7)'    "did not find test-unstable-7 alias"
    assert_line 18 'test-unstable-8 -> 0.1.8 (-> v0.1.8)'    "did not find test-unstable-8 alias"
    assert_line 19 'test-unstable-9 -> 0.1.9 (-> v0.1.9)'    "did not find test-unstable-9 alias"
    
}

