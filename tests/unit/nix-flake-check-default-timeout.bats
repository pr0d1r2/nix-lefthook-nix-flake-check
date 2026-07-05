#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "outputs 120 on Darwin" {
    # shellcheck disable=SC2329
    uname() { echo "Darwin"; }
    export -f uname
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "120"
}

@test "outputs 60 on Linux" {
    # shellcheck disable=SC2329
    uname() { echo "Linux"; }
    export -f uname
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "60"
}

@test "respects LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT override" {
    # shellcheck disable=SC2030
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=300
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "300"
}

@test "falls back to Darwin default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is non-numeric" {
    # shellcheck disable=SC2329
    uname() { echo "Darwin"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=abc
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "120"
}

@test "falls back to Linux default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is non-numeric" {
    # shellcheck disable=SC2329
    uname() { echo "Linux"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=abc
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "60"
}

@test "falls back to Darwin default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is zero" {
    # shellcheck disable=SC2329
    uname() { echo "Darwin"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=0
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "120"
}

@test "falls back to Linux default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is zero" {
    # shellcheck disable=SC2329
    uname() { echo "Linux"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=0
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "60"
}

@test "falls back to Darwin default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is negative" {
    # shellcheck disable=SC2329
    uname() { echo "Darwin"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=-5
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "120"
}

@test "falls back to Linux default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is negative" {
    # shellcheck disable=SC2329
    uname() { echo "Linux"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=-5
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "60"
}

@test "falls back to Darwin default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is a float" {
    # shellcheck disable=SC2329
    uname() { echo "Darwin"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=1.5
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "120"
}

@test "falls back to Linux default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is a float" {
    # shellcheck disable=SC2329
    uname() { echo "Linux"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=1.5
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "60"
}

@test "falls back to Darwin default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is mixed alphanumeric" {
    # shellcheck disable=SC2329
    uname() { echo "Darwin"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=12abc
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "120"
}

@test "falls back to Linux default when LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT is mixed alphanumeric" {
    # shellcheck disable=SC2329
    uname() { echo "Linux"; }
    export -f uname
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=12abc
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "60"
}

@test "falls through to 60 for unknown uname -s output" {
    # shellcheck disable=SC2329
    uname() { echo "FreeBSD"; }
    export -f uname
    run bash nix-flake-check-default-timeout.sh
    assert_success
    assert_output "60"
}
