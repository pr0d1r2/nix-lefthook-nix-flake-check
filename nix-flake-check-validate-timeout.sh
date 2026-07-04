# shellcheck shell=bash
# Validate that $1 is a positive integer. Exit 0 if valid, exit 1 otherwise.

printf '%s' "${1:-}" | grep -qE '^[1-9][0-9]*$' || exit 1
