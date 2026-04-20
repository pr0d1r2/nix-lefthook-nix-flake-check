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
