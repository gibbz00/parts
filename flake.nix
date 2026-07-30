{
  inputs = {
    # Base
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # pre-commit
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust
    crane.url = "github:ipetkov/crane";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, ... }:
      let
        pre-commit-module = flake-parts-lib.importApply ./modules/pre-commit.nix { inherit inputs; };
        rust-module = flake-parts-lib.importApply ./modules/rust { inherit inputs; };
      in
      {
        systems = nixpkgs.lib.systems.flakeExposed;

        imports = [
          pre-commit-module
        ];

        perSystem =
          { config, pkgs, ... }:
          {
            devShells.default = pkgs.mkShell {
              name = "flake-parts";

              inputsFrom = [
                config.devShells.pre-commit
              ];
            };
          };

        flake.flakeModule = {
          pre-commit = pre-commit-module;
          rust = rust-module;
        };
      }
    );
}
