#!/usr/bin/env bash

if [ -z "${CONFIRM_SCRIPT:-}" ]; then
  echo "CONFIRM_SCRIPT must be set" >&2
  exit 1
fi

bash "$CONFIRM_SCRIPT" "$@"
