# Flake Parts - Commonly Reused Project Setups

## Modules

#### `pre-commit`

Pulls in the [git-hooks](https://flake.parts/options/git-hooks-nix.html) flake part for setting up common [pre-commit](https://pre-commit.com/) hooks when entering its exported devShell.

pre-commit checks will also be made part of the flake checks.

## Example Usage

Pick and chose from the [flake-parts](https://flake.parts/index.html) modules located in `modules/`.
Most modules integrate a tool (e.g `pre-commit`) by including a corresponding Nix bridge (`git-hooks`).

Then, in another project's `flake.nix`:

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # 1): Use this repo as a flake input.
    rust-flake-parts = {
      url = "github:gibbz00/rusty-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [
        # 2) Import any module exported in this project's flake.nix
        inputs.rust-flake-parts.flakeModule.pre-commit
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          # 3) Define a project specific devShell
          devShells.default = pkgs.mkShell {
            name = "my-awesome-project";

            # 4) Extend with a devShell exported by an imported module
            inputsFrom = [
              config.devShells.pre-commit
            ];

            packages = with pkgs; [ cowsay ];
          };
        };
    };
}
```

Then:

```sh
# Runs check from the imported modules, i.e. the base pre-commit checks.
nix flake check
```

```sh
# Enter the combined dev environment, i.e. one where cowsay and pre-commit is available.
nix develop
```
