#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "lefthook.yml pre-commit has markdownlint command" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep "markdownlint:"'
  assert_success
}

@test "lefthook.yml pre-push has markdownlint command" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep "markdownlint:"'
  assert_success
}

@test "lefthook.yml markdownlint pre-commit uses glob for md files" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -A2 "markdownlint:" | grep "glob"'
  assert_success
  assert_output --partial "*.md"
}

@test "lefthook.yml markdownlint pre-push uses glob for md files" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -A2 "markdownlint:" | grep "glob"'
  assert_success
  assert_output --partial "*.md"
}

@test "lefthook.yml markdownlint pre-commit has timeout" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -A3 "markdownlint:" | grep "run:"'
  assert_success
  assert_output --partial "timeout"
}

@test "lefthook.yml markdownlint pre-push has timeout" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -A3 "markdownlint:" | grep "run:"'
  assert_success
  assert_output --partial "timeout"
}

@test "lefthook.yml markdownlint pre-commit uses staged_files" {
  run bash -c 'awk "/^pre-commit:/,/^pre-push:/" lefthook.yml | grep -A3 "markdownlint:" | grep "run:"'
  assert_success
  assert_output --partial "{staged_files}"
}

@test "lefthook.yml markdownlint pre-push uses all_files" {
  run bash -c 'awk "/^pre-push:/,0" lefthook.yml | grep -A3 "markdownlint:" | grep "run:"'
  assert_success
  assert_output --partial "{all_files}"
}
