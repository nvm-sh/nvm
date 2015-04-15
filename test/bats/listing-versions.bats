#!/usr/bin/env bats

load test_helper

NVM_SRC_DIR="${BATS_TEST_DIRNAME}/../.."

setup() {
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
    mkdir src alias
    load "${NVM_SRC_DIR}/nvm.sh"
}

teardown() {
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
}

@test 'Listing versions/Running "nvm ls 0.0.2" should display only version 0.0.2.' {

    mkdir -p v0.0.2
    mkdir -p v0.0.20

    run nvm ls 0.0.2
    assert_match ${lines[0]} "v0.0.2" "nvm ls 0.0.2 must contain v0.0.2"

    run nvm ls 0.0.2
    assert_nomatch "$output" "v0.0.20"  "nvm ls 0.0.2 must NOT contain v0.0.20"
}

@test 'Listing versions/Running "nvm ls 0.2" should display only 0.2.x versions.' {

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

@test 'Listing versions/Running "nvm ls foo" should return a nonzero exit code when not found' {

    run nvm ls nonexistent_version
    assert_equal 3 "$status"
}

@test 'Listing versions/Running "nvm ls node" should return a nonzero exit code when not found' {

    run nvm ls node
    assert_equal 3 "$status"
}

@test 'Listing versions/Running "nvm ls stable" and "nvm ls unstable" should return the appropriate implicit alias' {

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

## merged two tests here
# `nvm ls` and `nvm ls system`
@test 'Listing versions/Running "nvm ls [system]" should include "system" when appropriate' {

    mkdir -p v0.{0,3}.{1,3,9}

    nvm_has_system_node() { return 0; }
    run nvm ls system
    assert_match "$output" system '"nvm ls system" did not contain "system" when system node is present'

    run nvm ls
    assert_match "$output" system '"nvm ls" did not contain "system" when system node is present'
    
    nvm_has_system_node() { return 1; }
    run nvm ls system
    assert_nomatch "$output" system '"nvm ls system" contained "system" when system node is NOT present'

    run nvm ls
    assert_nomatch "$output" system '"nvm ls" contained "system" when system node is NOT present'
}

@test 'Listing versions/Running "nvm ls" should display all installed versions.' {

    mkdir -p v0.{0,3}.{1,3,9}

    run nvm ls
    assert_match "$output" v0.0.1
    assert_match "$output" v0.0.3
    assert_match "$output" v0.0.9
    assert_match "$output" v0.3.1
    assert_match "$output" v0.3.3
    assert_match "$output" v0.3.9
}

@test 'Listing versions/Running "nvm ls" should filter out ".nvm"' {

    mkdir -p v0.{1,2}.3

    run nvm ls
    assert_nomatch "$output" "^ *\." "running 'nvm ls' should filter out dotfiles"
}

@test 'Listing versions/Running "nvm ls" should filter out "versions"' {

    mkdir -p v0.{1,2}.3 versions
    run nvm ls
    assert_nomatch "$output" versions "running 'nvm ls' should filter out 'versions'"
}

@test 'Listing versions/Running "nvm ls" should list versions both in and out of the "versions" directory' {

    mkdir -p versions/v0.12.1
    mkdir -p v0.1.3

    run nvm ls 0.12
    assert_match "$output" "v0.12.1" "'nvm ls' did not list a version in versions/"

    run nvm ls 0.1
    assert_match "$output" "v0.1.3" "'nvm ls' did not list a version NOT in versions/"

}

@test 'Listing versions/Running "nvm ls" with node-like versioning vx.x.x should only list a matched version' {

    mkdir -p v0.1.2

    run nvm ls v0.1
    assert_match "$output" "v0.1.2"

    run nvm ls v0.1.2
    assert_match "$output" "v0.1.2"

    run nvm ls v0.1.
    assert_match "$output" "v0.1.2"
    
    run nvm ls v0.1.1
    assert_nomatch "$output" "v0.1.2"
    assert_match   "$output" "N/A"
}
