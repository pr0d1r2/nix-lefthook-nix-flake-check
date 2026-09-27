#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"

  TEST_TEMP="$(mktemp -d)"
  cp .envrc "$TEST_TEMP/.envrc"
}

teardown() {
  rm -rf "$TEST_TEMP"
}

@test "watches dev.sh for changes" {
  run bash -c '
    watch_file() { for f in "$@"; do echo "$f"; done; }
    use() { :; }
    source "'"$TEST_TEMP/.envrc"'"
  '
  assert_success
  assert_line "dev.sh"
}

@test "watches flake.nix for changes" {
  run bash -c '
    watch_file() { for f in "$@"; do echo "$f"; done; }
    use() { :; }
    source "'"$TEST_TEMP/.envrc"'"
  '
  assert_success
  assert_line "flake.nix"
}

@test "watches flake.lock for changes" {
  run bash -c '
    watch_file() { for f in "$@"; do echo "$f"; done; }
    use() { :; }
    source "'"$TEST_TEMP/.envrc"'"
  '
  assert_success
  assert_line "flake.lock"
}

@test "watches lefthook-nix-flake-check.sh for changes" {
  run bash -c '
    watch_file() { for f in "$@"; do echo "$f"; done; }
    use() { :; }
    source "'"$TEST_TEMP/.envrc"'"
  '
  assert_success
  assert_line "lefthook-nix-flake-check.sh"
}

@test "uses flake" {
  run bash -c '
    watch_file() { :; }
    use() { echo "use $*"; }
    source "'"$TEST_TEMP/.envrc"'"
  '
  assert_success
  assert_line "use flake"
}
