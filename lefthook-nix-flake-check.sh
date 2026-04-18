# shellcheck shell=bash
# Run nix flake check to catch evaluation errors.
# Usage: lefthook-nix-flake-check
# NOTE: sourced by writeShellApplication — no shebang or set needed.

exec nix flake check
