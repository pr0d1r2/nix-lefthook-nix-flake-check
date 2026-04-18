# nix-lefthook-nix-flake-check

[![CI](https://github.com/pr0d1r2/nix-lefthook-nix-flake-check/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-nix-flake-check/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [nix flake check](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-check) runner, packaged as a Nix flake.

Runs `nix flake check` to catch evaluation errors, type mismatches, and missing outputs at commit time.

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
      glob: "*.nix"
      run: timeout ${LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT:-60} nix flake check
```

### Configuring timeout

The default timeout is 60 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT=120
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

## License

MIT
