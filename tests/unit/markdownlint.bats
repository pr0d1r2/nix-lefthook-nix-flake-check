#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"

  PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
  MARKDOWNLINT_CONFIG="$PROJECT_ROOT/.markdownlint.yml"
}

@test ".markdownlint.yml exists" {
  [ -f "$MARKDOWNLINT_CONFIG" ]
}

@test ".markdownlint.yml disables MD013 line length" {
  run grep 'MD013: false' "$MARKDOWNLINT_CONFIG"
  assert_success
}

@test ".markdownlint.yml disables MD041 first line heading" {
  run grep 'MD041: false' "$MARKDOWNLINT_CONFIG"
  assert_success
}

@test "SPEC.md passes markdownlint" {
  cd "$PROJECT_ROOT"
  run lefthook-markdownlint SPEC.md
  assert_success
}
