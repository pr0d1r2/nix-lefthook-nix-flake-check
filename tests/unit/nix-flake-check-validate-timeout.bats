#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "accepts a positive integer" {
    run bash nix-flake-check-validate-timeout.sh 42
    assert_success
}

@test "accepts 1 as smallest positive integer" {
    run bash nix-flake-check-validate-timeout.sh 1
    assert_success
}

@test "accepts large positive integer" {
    run bash nix-flake-check-validate-timeout.sh 300
    assert_success
}

@test "rejects non-numeric string" {
    run bash nix-flake-check-validate-timeout.sh abc
    assert_failure
}

@test "rejects zero" {
    run bash nix-flake-check-validate-timeout.sh 0
    assert_failure
}

@test "rejects negative number" {
    run bash nix-flake-check-validate-timeout.sh -5
    assert_failure
}

@test "rejects empty argument" {
    run bash nix-flake-check-validate-timeout.sh ""
    assert_failure
}

@test "rejects no argument" {
    run bash nix-flake-check-validate-timeout.sh
    assert_failure
}

@test "rejects float" {
    run bash nix-flake-check-validate-timeout.sh 1.5
    assert_failure
}

@test "rejects mixed alphanumeric" {
    run bash nix-flake-check-validate-timeout.sh 12abc
    assert_failure
}
