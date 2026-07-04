# shellcheck shell=bash
# Output the effective nix-flake-check timeout.
# Respects LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT; otherwise 120 on Darwin, 60 on Linux.

if [ -n "${LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT:-}" ] && bash nix-flake-check-validate-timeout.sh "$LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT"; then
    echo "$LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT"
elif [ "$(uname -s)" = "Darwin" ]; then
    echo 120
else
    echo 60
fi
