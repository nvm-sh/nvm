#!/usr/bin/env bats

load test_helper

NVM_SRC_DIR="${BATS_TEST_DIRNAME}/../.."
source "${NVM_SRC_DIR}/nvm.sh"

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
    assert_equal "$status" "0" "nvm command defined"
}

@test "Running 'nvm alias' should create a file in the alias directory." {
    run nvm alias test v0.1.2
    [ "$status" -eq 0 ]
    result=$(cat "alias/test")
    assert_equal "$result" "v0.1.2" "expected new alias"
}

@test './Listing versions/Running "nvm ls 0.0.2" should display only version 0.0.2.' {

    mkdir -p v0.0.2
    mkdir -p v0.0.20

    run nvm ls 0.0.2
    assert_match ${lines[0]} "v0.0.2" "nvm ls 0.0.2 must contain v0.0.2"

    run nvm ls 0.0.2
    assert_nomatch "$output" "v0.0.20"  "nvm ls 0.0.2 must NOT contain v0.0.20"
}

@test './Listing versions/Running "nvm ls 0.2" should display only 0.2.x versions.' {

    mkdir -p v0.1.3
    mkdir -p v0.2.3
    mkdir -p v0.20.3

    run nvm ls 0.1
    assert_nomatch "$output" "v0.2.3"  "nvm ls 0.1 should not contain v0.2.3"
    assert_nomatch "$output" "v0.20.3" "nvm ls 0.1 should not contain v0.20.3"    
    assert_match   "$output" "v0.1.3"  "nvm ls 0.1 should contain v0.1.3"

    run nvm ls 0.2
    assert_match   "$output" "v0.2.3"  "nvm ls 0.2 should contain v0.2.3"
    assert_nomatch "$output" "v0.20.3" "nvm ls 0.2 should not contain v0.20.3"    
    assert_nomatch "$output" "v0.1.3"  "nvm ls 0.2 should not contain v0.1.3"
}

@test './Listing versions/Running "nvm ls foo" should return a nonzero exit code when not found' {

    run nvm ls nonexistent_version
    assert_equal 3 "$status"
}

@test './Listing versions/Running "nvm ls node" should return a nonzero exit code when not found' {

    run nvm ls node
    assert_equal 3 "$status"
}

@test './Listing versions/Running "nvm ls stable" and "nvm ls unstable" should return the appropriate implicit alias' {

    mkdir -p v0.2.3
    mkdir -p v0.3.3

    run nvm ls stable
    assert_match "$output" "0.2.3" "expected 'nvm ls stable' to give STABLE_VERSION"

    run nvm ls unstable
    assert_match "$output" "0.3.3" "expected 'nvm ls unstable' to give UNSTABLE_VERSION"
    mkdir -p v0.1.2
    nvm alias stable 0.1

    run nvm ls stable
    assert_nomatch "$output" "0.2.3" "expected 'nvm ls stable' to not give old STABLE_VERSION"
    assert_match   "$output" "v0.1.2" "expected 'nvm ls stable' to give new STABLE_VERSION"
}

