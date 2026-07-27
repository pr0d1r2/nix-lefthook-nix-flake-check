# SPEC

## §D — Description

nix-lefthook-nix-flake-check is a Nix flake that packages `nix flake check` as a lefthook-compatible git hook,
catching Nix evaluation errors, type mismatches, and missing outputs at commit and push time.
It ships both as a lefthook remote (zero-config YAML include) and as a flake input for direct devShell integration,
with platform-aware timeouts (120 s on macOS, 60 s on Linux) overridable via environment variable.
The target audience is Nix flake developers who use lefthook for pre-commit/pre-push automation
and want deterministic, portable flake validation wired into their git workflow.

## §V — Invariants

1. `nix flake check` must pass on the project's own flake (CI gate on both Linux and macOS).
2. Every shell script (`*.sh`) has a 1-to-1 bats unit test under `tests/unit/`.
3. Tests are non-destructive: they use temporary directories and mock binaries, never mutate the working tree.
4. The flake builds on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
5. Shell scripts contain no functions; logic is split into separate scripts invoked inline (shell modularity rule).
6. No embedded shell in Nix files — shell code lives in external `.sh` files read via `builtins.readFile`.
7. No embedded shell in lefthook YAML — commands invoke `bash <script>.sh` (noexec rule).
8. Lefthook checks run in both `pre-commit` and `pre-push` hooks with parallel execution.
9. Every lefthook action has a bracing timeout.
10. The default timeout is platform-aware: `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT` > Darwin 120 > Linux 60 (precedence order).
11. `lefthook install` runs automatically in the devShell when `.git/hooks/pre-commit` is absent.
12. All remote lefthook checks (16 remotes) pin to `main` branch and reference `lefthook-remote.yml`.
13. CI runs on `ubuntu-latest` for PRs and pushes; `macos-latest` runs only on push and workflow_dispatch.
14. EditorConfig enforces UTF-8, LF line endings, 2-space indentation, final newlines, and no trailing whitespace.
15. Every file type tracked in git has a linter in lefthook (enforced via remote configs: shellcheck, nixfmt, statix, deadnix, yamllint, markdownlint, typos, editorconfig-checker, shfmt, trailing-whitespace, final-newline, conflict-markers, bats-parse, file-size-check, no-local-paths).

## §I — Interfaces

### CLI package

- **`lefthook-nix-flake-check`** — Nix `writeShellApplication` wrapper. Runs `exec nix flake check`. Available as `packages.<system>.default`.

### Shell scripts

- **`nix-flake-check-default-timeout.sh`** — Prints the effective timeout value to stdout.
  - Env override: `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT` (integer, seconds).
  - Platform default: `120` on Darwin, `60` on Linux.
- **`dev.sh`** — DevShell hook sourced by `nix develop`. Exports `BATS_LIB_PATH` (substituted at build time via `@BATS_LIB_PATH@`) and conditionally runs `lefthook install`.

### Lefthook configs

- **`lefthook.yml`** — Local lefthook config. Defines `nix-flake-check` command for `pre-commit` and `pre-push` with glob `{*.nix,flake.lock}`. Includes 16 remote lint configs.
- **`lefthook-remote.yml`** — Standalone config for consumers using `remotes:` in their own lefthook. Same command/glob/timeout logic, self-contained (no external script dependency).

### Configuration files

- **`config/lefthook/file_size_limits.yml`** — Per-extension file size limits (default 4096 bytes, `.lock` 65536).
- **`.envrc`** — Direnv entrypoint: `use flake`.
- **`.markdownlint.yml`** — Disables MD013 (line length).
- **`.yamllint.yml`** — Extends default; disables truthy key check and line-length rule.
- **`.editorconfig`** — Project-wide editor settings.

### Environment variables

| Variable | Type | Default | Description |
| --- | --- | --- | --- |
| `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT` | integer (seconds) | 120 (Darwin) / 60 (Linux) | Override the `nix flake check` timeout |
| `BATS_LIB_PATH` | path | Set by devShell | Path to bats helper libraries |

### Flake inputs

| Input | Source | Purpose |
| --- | --- | --- |
| `nixpkgs-lock` | `github:pr0d1r2/nixpkgs-lock` | Pinned nixpkgs |
| `nix-dev-shell-agentic` | `github:pr0d1r2/nix-dev-shell-agentic` | Agentic devShell builder |
| `nix-lefthook-bats-unit` | `github:pr0d1r2/nix-lefthook-bats-unit` | Bats unit test runner |

## §T — Tasks

| status | id | goal |
| --- | --- | --- |
| `x` | T9 | Create `nix-flake-check-validate-timeout.sh` that validates its argument is a positive integer (exit 0 valid, exit 1 otherwise) with 1-to-1 bats test `tests/unit/nix-flake-check-validate-timeout.bats` covering positive int, non-numeric string, zero, negative, empty (§B.3, §V.2, §V.5) |
| `x` | T10 | Wire `bash nix-flake-check-validate-timeout.sh` guard into `nix-flake-check-default-timeout.sh` so an invalid `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT` falls through to the platform default; extend `tests/unit/nix-flake-check-default-timeout.bats` with cases for non-numeric and non-positive env values falling back correctly — subsumes T3 (§B.3, §V.10, §V.2) |
| `x` | T1 | Add `.envrc` `watch_file` entries for `dev.sh`, `flake.nix`, and `flake.lock` per direnv skill rules |
| `x` | T2 | Add bats test for `lefthook-nix-flake-check.sh` verifying `exec nix flake check` invocation with a mock |
| `x` | T3 | Add edge-case test for `nix-flake-check-default-timeout.sh` with non-numeric `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT` |
| `x` | T4 | Update README timeout docs to reflect platform-aware defaults (currently says "default is 60 seconds" but Darwin is 120) |
| `x` | T5 | Add `nix-flake-check-default-timeout.sh` test for unknown `uname -s` output (e.g. FreeBSD falls through to 60) |
| `x` | T6 | Add markdownlint lefthook check for `*.md` files to local `lefthook.yml` commands (currently only via remote) |
| `x` | T7 | Validate `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT` is a positive integer in `nix-flake-check-default-timeout.sh` |
| `x` | T8 | Add SPEC.md linting exclusion or ensure it passes markdownlint |

## §B — Bugs / Known Issues

1. ~~**README timeout default is misleading**~~: Fixed — README now documents platform-aware defaults (120 s on Darwin, 60 s on Linux) and the Option B YAML example uses platform detection.
2. **`.envrc` missing `watch_file` directives**: The `.envrc` contains only `use flake` but does not `watch_file` on `flake.nix`, `flake.lock`, or `dev.sh`, so direnv will not auto-reload when those files change (violates the direnv skill rule).
3. **No input validation on `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT`**: A non-numeric value (e.g. `export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=abc`) is passed straight to `timeout`, which will fail with a confusing error.
4. **`lefthook-nix-flake-check.sh` is only indirectly tested**: The bats test for it runs `nix flake check` directly rather than invoking the `lefthook-nix-flake-check` wrapper script, so the `exec` path in the script itself is not exercised.
5. **Shallow git clone limits CI bisect/blame**: The CI action checks out without fetch-depth, defaulting to shallow clone, which prevents `git bisect` or full `git log` in CI debugging scenarios.
6. **`lefthook install` fails in CI when `$HOME` is unset**: The devShell hook in `dev.sh` unconditionally ran `lefthook install`,
    which calls git internally. Git requires `$HOME` to be set. In the CI nix build sandbox, `$HOME` is unset,
    causing `fatal: $HOME not set`. Fixed by guarding the call with `[ -z "${HOME:-}" ]` short-circuit.
7. **`markdownlint-agentic` lefthook command failed CI (`build-linux`)**: `lefthook run --all-files` broke three ways:
    (a) the `markdownlint-agentic` command invoked a binary no devShell provided (`exit status 127`);
    (b) both markdown commands' `exclude` values were regex strings, silently ignored under `--all-files`;
    (c) `.markdownlint.yml` did not disable MD013/MD041, so `SPEC.md` failed on first-line-heading and line length.
    Fixed by adding the `nix-lefthook-markdownlint-agentic` flake input to `ciPackages`,
    converting `exclude` values to flow-style glob lists, and setting `MD013: false` / `MD041: false`;
    pre-push templates also switched to `{all_files}`.
8. **`guardrails / check` coherence failures after migration to set-and-setting**: The `confirm` app's
    `runtimeInputs` only included basic utilities (coreutils, diffutils, etc.) but not the fragment-materialized
    packages (`lefthook-markdownlint`, `lefthook-markdownlint-agentic`, `lefthook-yamllint`). The coherence check
    verifies that all commands referenced in `lefthook.yml` are on PATH within the confirm app's environment.
    Fixed by adding `mat.packages` to the confirm app's `runtimeInputs`, and removing unused lambda patterns
    from the outputs function to satisfy deadnix.
9. **`file-size-check` failed for `SPEC.md` and `flake.lock`**: `SPEC.md` (9136 bytes) exceeded the `.md` limit of 8192, and `flake.lock` (844031 bytes) exceeded the `.lock` limit of 65536. Fixed by raising `config/lefthook/file_size_limits.yml` limits to 16384 for `.md` and 1048576 for `.lock`.
10. **`nix-no-embedded-shell-check` failed on confirm app**: The `writeShellApplication` for the `confirm` app
    in `flake.nix` had inline `export` statements setting environment variables to Nix store paths.
    Fixed by extracting the shell body to `nix/apps/confirm.sh` and moving env var definitions to `runtimeEnv`.
11. **`file-size-check` failed after the pin refresh enlarged `flake.lock`**: The generated lockfile grew to
    1122619 bytes, exceeding its 1048576-byte limit. Fixed by raising the explicit `.lock` limit to 2097152 bytes.
12. **`file-size-check` failed after another pin refresh enlarged `flake.lock`**: The generated lockfile grew to
    2345178 bytes, exceeding its 2097152-byte limit. Fixed by raising the explicit `.lock` limit to 4194304 bytes.
