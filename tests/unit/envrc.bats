#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"

  TMPDIR="$(mktemp -d)"
  cp .envrc "$TMPDIR/.envrc"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "watches dev.sh for changes" {
  run bash -c '
    watch_file() { for f in "$@"; do echo "$f"; done; }
    use() { :; }
    source "'"$TMPDIR/.envrc"'"
  '
  assert_success
  assert_line "dev.sh"
}

@test "watches flake.nix for changes" {
  run bash -c '
    watch_file() { for f in "$@"; do echo "$f"; done; }
    use() { :; }
    source "'"$TMPDIR/.envrc"'"
  '
  assert_success
  assert_line "flake.nix"
}

@test "watches flake.lock for changes" {
  run bash -c '
    watch_file() { for f in "$@"; do echo "$f"; done; }
    use() { :; }
    source "'"$TMPDIR/.envrc"'"
  '
  assert_success
  assert_line "flake.lock"
}

@test "uses flake" {
  run bash -c '
    watch_file() { :; }
    use() { echo "use $*"; }
    source "'"$TMPDIR/.envrc"'"
  '
  assert_success
  assert_line "use flake"
}
