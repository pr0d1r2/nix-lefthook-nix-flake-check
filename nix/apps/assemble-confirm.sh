#!/usr/bin/env bash

bash "$REAL_ASSEMBLE_SCRIPT" "$@"
# shellcheck disable=SC2154
sed -i 's/{push_files}/{all_files}/g' "$out/lefthook.yml"
