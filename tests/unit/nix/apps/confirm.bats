#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"

  TMP="$BATS_TEST_TMPDIR"
}

@test "runs the script pointed to by CONFIRM_SCRIPT" {
  cat >"$TMP/mock-confirm.sh" <<'SH'
#!/usr/bin/env bash
echo "confirm-executed"
SH
  chmod +x "$TMP/mock-confirm.sh"
  CONFIRM_SCRIPT="$TMP/mock-confirm.sh" run bash nix/apps/confirm.sh
  assert_success
  assert_output "confirm-executed"
}

@test "forwards exit code from CONFIRM_SCRIPT" {
  cat >"$TMP/failing-confirm.sh" <<'SH'
#!/usr/bin/env bash
exit 42
SH
  chmod +x "$TMP/failing-confirm.sh"
  CONFIRM_SCRIPT="$TMP/failing-confirm.sh" run bash nix/apps/confirm.sh
  assert_failure
  [ "$status" -eq 42 ]
}

@test "fails when CONFIRM_SCRIPT is not set" {
  unset CONFIRM_SCRIPT
  run bash nix/apps/confirm.sh
  assert_failure
}
