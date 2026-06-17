#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
    load "${BATS_LIB_PATH}/bats-file/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "passes on a valid flake" {
    mkdir -p "$TMP/valid-flake"
    cat > "$TMP/valid-flake/flake.nix" <<'NIX'
{
  description = "test flake";
  outputs = { self }: { };
}
NIX
    cd "$TMP/valid-flake"
    git init
    git add flake.nix
    run nix flake check
    assert_success
}

@test "lefthook.yml pre-commit uses platform-aware timeout script" {
    run grep 'bash nix-flake-check-default-timeout.sh' lefthook.yml
    assert_success
}

@test "lefthook.yml uses timeout script in both hooks" {
    run bash -c 'grep -c "bash nix-flake-check-default-timeout.sh" lefthook.yml'
    assert_success
    assert_output "2"
}

@test "lefthook-remote.yml pre-commit has Darwin 120 default" {
    run grep 'Darwin.*120' lefthook-remote.yml
    assert_success
}

@test "lefthook-remote.yml pre-commit has Linux 60 default" {
    run grep 'echo 60' lefthook-remote.yml
    assert_success
}

@test "lefthook-remote.yml respects LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT" {
    run grep 'LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT' lefthook-remote.yml
    assert_success
}

@test "fails on a flake with syntax error" {
    mkdir -p "$TMP/bad-flake"
    cat > "$TMP/bad-flake/flake.nix" <<'NIX'
{
  description = "broken";
  outputs = { self nixpkgs }: { };
}
NIX
    cd "$TMP/bad-flake"
    git init
    git add flake.nix
    run nix flake check
    assert_failure
}
