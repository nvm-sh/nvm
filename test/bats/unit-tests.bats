#!/usr/bin/env bats

load test_helper

NVM_SRC_DIR="${BATS_TEST_DIRNAME}/../.."
source "${NVM_SRC_DIR}/nvm.sh"

FIXTURES_DIR="${NVM_SRC_DIR}/test/fixtures"

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
    load "${NVM_SRC_DIR}/nvm.sh"
}

teardown() {
    test_debug && echo 'teardown' >&2
    NVM_DIR="${BATS_TMPDIR}"
    cd "${NVM_DIR}"
    rm -Rf src alias v*
}

@test './Unit tests/nvm_alias' {
    test_implementing && skip

    run nvm_alias
    assert_equal 1 "$status" "nvm_alias should exit with code 1 for missing"
    assert_match "$output" "An alias is required."

    run nvm_alias nonexistent
    assert_equal 2 "$status" "nvm_alias should exit with code 2 for nonexistent"
    assert_match "$output" "Alias does not exist."
    
    run nvm alias test "0.10"
    run nvm_alias test
    assert_match "$output" "0.10" "nvm_alias test produced wrong output"
}

@test './Unit tests/nvm_checksum' {
    test_implementing && skip

    mkdir -p tmp
    touch tmp/emptyfile
    echo -n "test" > tmp/testfile

    run nvm_checksum tmp/emptyfile "da39a3ee5e6b4b0d3255bfef95601890afd80709"
    assert_equal 0 "$status" "nvm_checksum on empty file did not match SHA1 of empty string"

    run nvm_checksum tmp/testfile  "da39a3ee5e6b4b0d3255bfef95601890afd80709"
    assert_equal 1 "$status" "nvm_checksum allowed a bad checksum"
}

@test './Unit tests/nvm_find_up' {
    test_implementing && skip

    mkdir -p tmp_nvm_find_up/a/b/c/d
    touch tmp_nvm_find_up/test
    touch tmp_nvm_find_up/a/b/c/test

    output="$(PWD=${PWD}/tmp_nvm_find_up/a nvm_find_up 'test')"
    assert_equal "${PWD}/tmp_nvm_find_up" "$output" "failed to find 1 dir up"

    output="$(PWD=${PWD}/tmp_nvm_find_up/a/b nvm_find_up 'test')"
    assert_equal "${PWD}/tmp_nvm_find_up" "$output" "failed to find 2 dirs up"
    
    output="$(PWD=${PWD}/tmp_nvm_find_up/a/b/c nvm_find_up 'test')"
    assert_equal "${PWD}/tmp_nvm_find_up/a/b/c" "$output" "failed to find in current dir"

    output="$(PWD=${PWD}/tmp_nvm_find_up/a/b/c/d nvm_find_up 'test')"
    assert_equal "${PWD}/tmp_nvm_find_up/a/b/c" "$output" "failed to find 1 up from current dir"

}

@test './Unit tests/nvm_format_version' {
    test_implementing && skip

    run nvm_format_version 0.1.2
    assert_equal "v0.1.2" "$output"

    run nvm_format_version 0.1
    assert_equal "v0.1.0" "$output"
}

@test './Unit tests/nvm_has' {
    test_implementing && skip

    nvm_has cat
    type cat

    ! nvm_has foobarbaz
    ! type foobarbaz
}

@test './Unit tests/nvm_has_system_node' {
    test_implementing && skip

    mkdir v0.1.2
    touch v0.1.2/node

    nvm use 0.1.2

    if command -v node; then
        nvm_has_system_node
    else
        ! nvm_has_system_node
    fi

    nvm deactivate

    if command -v node; then
        nvm_has_system_node
    else
        ! nvm_has_system_node
    fi
}

@test './Unit tests/nvm_ls_current' {
    test_implementing && skip

    nvm deactivate
    run nvm_ls_current
    assert_match "$output" "system" "when deactivated did not return 'system'"

    rm -fr nvm_ls_current_tmp
    mkdir -p nvm_ls_current_tmp
    TDIR="${PWD}/nvm_ls_current_tmp"

    ln -s "$(which which)" "$TDIR/which"
    ln -s "$(which dirname)" "$TDIR/dirname"
    
    output="$(PATH=${TDIR} nvm_ls_current || true)"
    assert_match "$output" "none" "when node not installed, nvm_ls_current should return 'none'"
    
    echo "#!/bin/bash" > node
    echo "echo 'VERSION FOO!'" >> node
    chmod a+x node

    nvm_tree_contains_path() {
        return 0
    }
    output="$(PATH=${TDIR} nvm_ls_current || true)"
    assert_match "$output" "none" "when activated 'nvm_ls_current' should return 'noe'"
}

@test './Unit tests/nvm_ls_remote' {
    test_implementing && skip

    nvm_download() {
        cat ${FIXTURES_DIR}/download.txt
    }

    run nvm_ls_remote foo
    assert_equal 3 "$status"
    assert_match "N/A" "$output" "nonexistent version should report N/A"

    run nvm_ls_remote
    assert_equal 0 "$status"
    assert_line 0 "v0.1.14" 
    assert_line 45 "v0.3.3" 
    assert_line 199 "v0.11.14"

    run nvm_ls_remote 0.3
    assert_equal 0 "$status"
    assert_line 0 "v0.3.0"
    assert_line 1 "v0.3.1"
    assert_line 2 "v0.3.2"
    assert_line 3 "v0.3.3"
    assert_line 4 "v0.3.4"
    assert_line 5 "v0.3.5"
    assert_line 6 "v0.3.6"
    assert_line 7 "v0.3.7"
    assert_line 8 "v0.3.8"

    run nvm_print_implicit_alias remote stable
    assert_match "$output" "0.10"

    run nvm_print_implicit_alias remote unstable
    assert_match "$output" "0.11"

    run nvm_ls_remote stable
    assert_match "$output" "0.10.32"

    run nvm_ls_remote unstable
    assert_match "$output" "0.11.14"
}


@test './Unit tests/nvm_num_version_groups' {
    test_implementing && skip
    
    assert_equal "0" "$(nvm_num_version_groups)"

    assert_equal "1" "$(nvm_num_version_groups a)"
    
    assert_equal "1" "$(nvm_num_version_groups 1)"   "1 should give 1"
    assert_equal "1" "$(nvm_num_version_groups v1)"  "v1 should give 1"
    assert_equal "1" "$(nvm_num_version_groups v1.)" "v1. should give 1"

    assert_equal "2" "$(nvm_num_version_groups 1.2)"   "1.2 should give 2"
    assert_equal "2" "$(nvm_num_version_groups v1.2)"  "v1.2 should give 2"
    assert_equal "2" "$(nvm_num_version_groups v1.2.)" "v1.2. should give 2"

    assert_equal "3" "$(nvm_num_version_groups 1.2.3)"   "1.2.3 should give 3"
    assert_equal "3" "$(nvm_num_version_groups v1.2.3)"  "v1.2.3 should give 3"
    assert_equal "3" "$(nvm_num_version_groups v1.2.3.)" "v1.2.3. should give 3"
}

@test './Unit tests/nvm_prepend_path' {
    test_implementing && skip

    TEST_PATH=/usr/bin:/usr/local/bin
    NEW_PATH=`nvm_prepend_path "$TEST_PATH" "$NVM_DIR/v0.2.5/bin"`

    assert_equal "$NVM_DIR/v0.2.5/bin:/usr/bin:/usr/local/bin" "$NEW_PATH" "Not correctly prepended: $NEW_PATH "

    EMPTY_PATH=
    NEW_PATH=`nvm_prepend_path "$EMPTY_PATH" "$NVM_DIR/v0.2.5/bin"`

    assert_equal "$NVM_DIR/v0.2.5/bin" "$NEW_PATH" "Not correctly prepended: $NEW_PATH "
}

@test './Unit tests/nvm_print_implicit_alias errors' {
    test_implementing && skip

    run nvm_print_implicit_alias
    assert_match "$output" "nvm_print_implicit_alias must be specified with local or remote as the first argument." "nvm_print_implicit_alias did not require local|remote as first argument"

    run nvm_print_implicit_alias foo
    assert_match "$output" "nvm_print_implicit_alias must be specified with local or remote as the first argument." "nvm_print_implicit_alias did not require local|remote as first argument"
    assert_equal "1" "$status"

    run nvm_print_implicit_alias local
    assert_match "$output" "Only implicit aliases 'stable' and 'unstable' are supported." "nvm_print_implicit_alias did not require stable|unstable as second argument"

    run nvm_print_implicit_alias local foo
    assert_match "$output" "Only implicit aliases 'stable' and 'unstable' are supported." "nvm_print_implicit_alias did not require stable|unstable as second argument"
    assert_equal "2" "$status"
}

@test './Unit tests/nvm_print_implicit_alias success' {
    test_implementing && skip

    mkdir -p v0.2.3 v0.3.4 v0.4.6 v0.5.7 v0.7.7
    
    run nvm_print_implicit_alias local stable
    assert_match "$output" "0.4"

    run nvm_print_implicit_alias local unstable
    assert_match "$output" "0.7"

    nvm_ls_remote() {
        echo "v0.4.3"
        echo "v0.5.4"
        echo "v0.6.6"
        echo "v0.7.7"
        echo "v0.9.7"
        echo "v0.4.3"
        echo "v0.5.4"
        echo "v0.6.6"
        echo "v0.7.7"
        echo "v0.9.7"
    }

    run nvm_print_implicit_alias remote stable
    assert_match "$output" "0.6"

    run nvm_print_implicit_alias remote unstable
    assert_match "$output" "0.9"
}

@test './Unit tests/nvm_remote_version' {
    test_implementing && skip

    nvm_ls_remote() {
        echo "N/A"
    }

    run nvm_remote_version foo
    assert_match "$output" "N/A"
    assert_equal "3" "$status"

    nvm_ls_remote() {
        echo "test output"
        echo "more test output"
        echo "pattern received: _$1_"
    }

    run nvm_remote_version foo
    assert_match "$output" "pattern received: _foo_"  "nvm_remote_version foo did not return last line only of nvm_ls_remote foo; got $OUTPUT"
    assert_equal "0" "$status"
}

@test './Unit tests/nvm_strip_path' {
    test_implementing && skip

    TEST_PATH=$NVM_DIR/v0.10.5/bin:/usr/bin:$NVM_DIR/v0.11.5/bin:$NVM_DIR/v0.9.5/bin:/usr/local/bin:$NVM_DIR/v0.2.5/bin

    STRIPPED_PATH=`nvm_strip_path "$TEST_PATH" "/bin"`

    assert_equal "/usr/bin:/usr/local/bin" "$STRIPPED_PATH" "Not correctly stripped: $STRIPPED_PATH "
    
}

@test './Unit tests/nvm_tree_contains_path' {
    test_implementing && skip

    mkdir -p tmp tmp2
    touch tmp/node tmp2/node

    run nvm_tree_contains_path
    assert_equal "2" "$status"
    assert_match "$output" "both the tree and the node path are required" "expected error messge with no args"

    nvm_tree_contains_path   tmp  tmp/node
    ! nvm_tree_contains_path tmp  tmp2/node
    ! nvm_tree_contains_path tmp2 tmp/node
    nvm_tree_contains_path   tmp2 tmp2/node    
}

@test './Unit tests/nvm_validate_implicit_alias' {
    test_implementing && skip

    run nvm_validate_implicit_alias
    assert_match "$output" "Only implicit aliases 'stable' and 'unstable' are supported." "nvm_validate_implicit_alias did not require stable|unstable"
    run nvm_validate_implicit_alias foo
    assert_match "$output" "Only implicit aliases 'stable' and 'unstable' are supported." "nvm_validate_implicit_alias did not require stable|unstable"
    assert_equal "1" "$status"

    nvm_validate_implicit_alias stable
    nvm_validate_implicit_alias unstable
}

@test './Unit tests/nvm_version_dir' {
#    test_implementing && skip

    run nvm_version_dir
    assert_equal "$NVM_DIR/versions" "$output"

    run nvm_version_dir new
    assert_equal "$NVM_DIR/versions" "$output"

    run nvm_version_dir old
    assert_equal "$NVM_DIR" "$output"
    
    run nvm_version_dir foo
    assert_match "$output" "unknown version dir"
    assert_unequal "0" "$status"
}

@test './Unit tests/nvm_version_greater' {
#    test_implementing && skip

    nvm_version_greater 0.10.0 0.2.12

    ! nvm_version_greater 0.10.0 0.20.12

    ! nvm_version_greater 0.10.0 0.10.0 
}

@test './Unit tests/nvm_version_path' {
#    test_implementing && skip

    run nvm_version_path foo
    assert_match "$output" "$NVM_DIR/foo"
    
    run nvm_version_path
    assert_unequal "0" "$status"

    run nvm_version_path v0.11.0
    assert_match "$output" "$NVM_DIR/v0.11.0"

    run nvm_version_path v0.12.0
    assert_match "$output" "$NVM_DIR/versions/v0.12.0"
}

