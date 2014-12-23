#!/usr/bin/env bats

load test_helper

NVM_SRC_DIR="${BATS_TEST_DIRNAME}/../.."
source "${NVM_SRC_DIR}/nvm.sh"

test_debug() {
    false # set to 'true' to get setup/teardown in test stderr
}

test_implementing() {
    false # set to 'false' to run all tests; set to 'true' to skip implemented tests
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

@test 'Running "nvm use system" should work as expected' {
    test_implementing && skip

    # NOTE: undocumented assumption of this test is
    # that node is installed on the test machine!
    # TODO: fix that, by using a mock

    nvm_has_system_node() { return 0; }
    run nvm use system
    assert_equal 0 "$status" "Expect success in using system node"
    assert_match "$output" 'Now using system version of node:'

    nvm_has_system_node() { return 1; }
    run nvm use system
    assert_equal 127 "$status" "Expect failure when no system node"
    assert_match "$output" 'System version of node not found.'
}

@test 'Running "nvm use x" should create and change the "current" symlink' {
    test_implementing && skip

    export NVM_SYMLINK_CURRENT=true

    mkdir -p v0.10.29
    nvm use 0.10.29
    rmdir v0.10.29

    # TODO make this a proper assert
    [ -L current ] # "expected 'current' symlink to be created"

    oldLink="$(readlink current)"

    assert_equal "$(basename $oldLink)" "v0.10.29" "Expected 'current' to point to v0.10.29 but was $oldLink"

    mkdir v0.11.13
    nvm use 0.11.13
    rmdir v0.11.13

    newlink="$(readlink current)"

    assert_equal "$(basename $newlink)" "v0.11.13" "Expected 'current' to point to v0.11.13 but was $newLink"
}

@test 'Running "nvm use x" should not create the "current" symlink if $NVM_SYMLINK_CURRENT is false' {
    test_implementing && skip

    test_symlink_made() {
        local arg="$1"

        mkdir v0.10.29

        if [ "$arg" = "undef" ]
        then
            unset NVM_SYMLINK_CURRENT
        else 
            NVM_SYMLINK_CURRENT="$arg"
        fi

        run nvm use 0.10.29
        run [ -L current ]
        result="$status"

        rm -f current
        rmdir v0.10.29

        return $result
    }

    test_symlink_made 'true'

    ! test_symlink_made 'false'
    ! test_symlink_made 'garbagevalue'
    ! test_symlink_made 0
    ! test_symlink_made 1
    ! test_symlink_made 'undef'
}

@test 'Sourcing nvm.sh should make the nvm command available.' {

    nvm
}
