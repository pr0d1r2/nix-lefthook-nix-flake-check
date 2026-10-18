# nix-lefthook-nix-flake-check

<!-- hallucinogen:autonomy-disclaimer start -->
> Read [LLM-DISCLAIMER](docs/LLM-DISCLAIMER.md) first. This repository is
> tended by an autonomous loop, and that file says what the loop may do here,
> what it may not, and what to check before trusting anything in this tree.
<!-- hallucinogen:autonomy-disclaimer end -->

[![CI](https://github.com/pr0d1r2/nix-lefthook-nix-flake-check/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-nix-flake-check/actions/workflows/ci.yml) [![NixOS 26.05](https://img.shields.io/badge/NixOS-26.05-blue.svg?logo=nixos)](https://nixos.org)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [nix flake check](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-check) runner, packaged as a Nix flake.

Runs `nix flake check` to catch evaluation errors, type mismatches, and missing outputs at commit time.

## Architecture

```mermaid
flowchart LR
  consumer["consumer lefthook.yml"] -->|"remotes"| remote["lefthook-remote.yml"]
  remote -->|"pre-commit: {*.nix,flake.lock}"| nix_flake_check["nix flake check"]
  remote -->|"pre-push: {*.nix,flake.lock}"| nix_flake_check["nix flake check"]
  nix_flake_check -->|"exit status"| consumer
```

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` — no flake input needed, `nix` is already available:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-nix-flake-check
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-nix-flake-check = {
  url = "github:pr0d1r2/nix-lefthook-nix-flake-check";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-nix-flake-check.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-commit:
  commands:
    nix-flake-check:
      glob: "{*.nix,flake.lock}"
      run: >
        timeout "${LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT:-$(
          if [ "$(uname -s)" = "Darwin" ]; then echo 120; else echo 60; fi
        )}" nix flake check
```

### Configuring timeout

The default timeout is platform-aware: 120 seconds on macOS (Darwin),
60 seconds on Linux. Override per-repo via environment variable:

```bash
export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=90
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-nix-flake-check  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

### Development architecture

```mermaid
flowchart LR
  envrc[".envrc"] -->|"use flake"| flake["flake.nix"]
  flake -->|"mkConsumerFlake"| sas["set-and-setting"]
  flake -->|"devShell"| shell["dev shell"]
  shell -->|"on entry"| devsh["dev.sh"]
  sas -->|"assembled hooks"| lh["lefthook.yml"]
  lh -->|"pre-commit / pre-push"| checks["linters, bats, nix flake check"]
  ci[".github/workflows/ci.yml"] -->|"guardrails.yml"| checks
```

## License

MIT
