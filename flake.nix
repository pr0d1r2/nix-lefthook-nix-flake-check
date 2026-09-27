{
  description = "Lefthook-compatible nix flake check runner";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting = {
      url = "github:pr0d1r2/set-and-setting";
      inputs.nixpkgs-lock.follows = "nixpkgs-lock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    set-and-setting.lib.mkConsumerFlake {
      inherit self nixpkgs set-and-setting;
      fragments = [
        "base"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
      extraPackages = pkgs: {
        default = pkgs.writeShellApplication {
          name = "lefthook-nix-flake-check";
          runtimeInputs = [ pkgs.nix ];
          text = builtins.readFile ./lefthook-nix-flake-check.sh;
        };
      };
      extraChecks = pkgs: {
        consumer-cli = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };
      src = ./.;
    };
}
