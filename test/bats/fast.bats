#!/usr/bin/env bats

load test_helper

NVM_SRC_DIR="${BATS_TEST_DIRNAME}/../.."
source "${NVM_SRC_DIR}/nvm.sh"

test_debug() {
    false # set to 'true' to get setup/teardown in test stderr
}

test_implementing() {
    true # set to 'false' to run all tests; set to 'true' to skip implemented tests
    # only used while porting to bats: remove afterward
}

setup() {
    test_debug && echo 'setup' >&2
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
    mkdir src alias
}

teardown() {
    test_debug && echo 'teardown' >&2
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
}

@test "'nvm' command defined in environment" {
    test_implementing && skip
    run nvm
    assert_equal "$status" "0" "nvm command defined"
}

@test "Running 'nvm alias' should create a file in the alias directory." {
    test_implementing && skip
    run nvm alias test v0.1.2
    [ "$status" -eq 0 ]
    result=$(cat "alias/test")
    assert_equal "$result" "v0.1.2" "expected new alias"
}

@test 'Running "nvm current" should display current nvm environment.' {
    test_implementing && skip

    run nvm deactivate

    run nvm current
    assert_match "$output" 'system|none' "expected 'none' or 'system' when deactivated"
}

@test 'Running "nvm deactivate" should unset the nvm environment variables.' {
    test_implementing && skip

    mkdir -p v0.2.3

    # v0.2.3 should not be active
    assert_nomatch "$PATH" ".*v0.2.3/.*/bin" "v0.2.3 should not be active yet"
    [ `expr $PATH : ".*v0.2.3/.*/bin"` = 0 ]

    x=$(nvm_version_path v0.2.3)

    # can't use 'run' -- sets up new env, PATH is lost
    nvm use 0.2.3

    assert_match $PATH "v0.2.3/.*/bin" "PATH should contain v0.2.3"
    assert_nomatch $NODE_PATH "v0.2.3/lib/node_modules" "NODE_PATH should not contain v0.2.3"

    nvm deactivate
    
    assert_nomatch $PATH "v0.2.3/.*/bin" "PATH should be cleaned of v0.2.3"
    assert_nomatch $NODE_PATH "v0.2.3/lib/node_modules" "NODE_PATH should not contain v0.2.3"
}

@test 'Running "nvm install" with "--reinstall-packages-from" requires a valid version' {
    test_implementing && skip

    mkdir -p v0.10.4

    nvm deactivate

    run nvm install v0.10.5 --reinstall-packages-from=0.11
    assert_equal 5 "$status" "should exit with code 5, invalid version"
    assert_match "$output" "If --reinstall-packages-from is provided, it must point to an installed version of node."

    run nvm install v0.10.5 --reinstall-packages-from=0.10.5
    assert_equal 4 "$status" "should exit with code 4, same version"
    assert_match "$output" "You can't reinstall global packages from the same version of node you're installing."

}

@test 'Running "nvm install" with an invalid version fails nicely' {
    test_implementing && skip

    run nvm install invalid.invalid
    assert_equal "3" "$status" "Invalid version, exit with status 3"
    assert_match "$output" "Version 'invalid.invalid' not found - try \`nvm ls-remote\` to browse available versions." "nvm installing an invalid version did not print a nice error message"
}

@test 'Running "nvm unalias" should remove the alias file.' {
    test_implementing && skip

    echo v0.1.2 > alias/test

    run nvm unalias test
    ! [ -e alias/test ]
}

@test 'Running "nvm uninstall" should remove the appropriate directory.' {
    test_implementing && skip

    mkdir -p v0.0.1 src/node-v0.0.1

    nvm uninstall v0.0.1
    ! [ -d 'v0.0.1' ]
    ! [ -d 'src/node-v0.0.1' ]
}

@test 'Running "nvm unload" should unset all function and variables.' {
    test_implementing && skip

    run type nvm
    assert_equal 0 "$status" "nvm not loaded"

    nvm unload

    run type nvm
    assert_equal 1 "$status" "nvm should have unloaded"
}

@test 'Running "nvm use foo" where "foo" is circular aborts' {
    test_implementing && skip

    echo 'foo' > alias/foo

    run nvm use foo
    assert_equal 8 "$status" "Expected exit code 8 (infinite alias loop)"
    assert_match "$output" 'The alias "foo" leads to an infinite loop. Aborting.'
}
