#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "lefthook.yml pre-commit has shfmt command" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep "shfmt:"'
  assert_success
}

@test "lefthook.yml pre-push has shfmt command" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep "shfmt:"'
  assert_success
}

@test "lefthook.yml shfmt pre-commit uses glob for sh files" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -A2 "shfmt:" | grep "glob"'
  assert_success
  assert_output --partial "*.sh"
}

@test "lefthook.yml shfmt pre-push uses glob for sh files" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -A2 "shfmt:" | grep "glob"'
  assert_success
  assert_output --partial "*.sh"
}

@test "lefthook.yml shfmt pre-commit uses 2-space indent" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -A3 "shfmt:" | grep "run:"'
  assert_success
  assert_output --partial "-i 2"
}

@test "lefthook.yml shfmt pre-push uses 2-space indent" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -A3 "shfmt:" | grep "run:"'
  assert_success
  assert_output --partial "-i 2"
}

@test "lefthook.yml shfmt pre-commit uses case indent" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -A3 "shfmt:" | grep "run:"'
  assert_success
  assert_output --partial "-ci"
}

@test "lefthook.yml shfmt pre-push uses case indent" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -A3 "shfmt:" | grep "run:"'
  assert_success
  assert_output --partial "-ci"
}

@test "lefthook.yml shfmt pre-commit has timeout" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -A3 "shfmt:" | grep "run:"'
  assert_success
  assert_output --partial "timeout"
}

@test "lefthook.yml shfmt pre-push has timeout" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -A3 "shfmt:" | grep "run:"'
  assert_success
  assert_output --partial "timeout"
}

@test "lefthook.yml shfmt pre-commit uses staged_files" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -A3 "shfmt:" | grep "run:"'
  assert_success
  assert_output --partial "{staged_files}"
}

@test "lefthook.yml shfmt pre-push uses all_files" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -A3 "shfmt:" | grep "run:"'
  assert_success
  assert_output --partial "{all_files}"
}

@test "all tracked sh files pass shfmt -i 2 -ci" {
  run bash -c 'git ls-files "*.sh" | xargs shfmt -d -i 2 -ci'
  assert_success
}
