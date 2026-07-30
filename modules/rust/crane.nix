localFlake:
{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    {
      lib,
      config,
      pkgs,
      system,
      ...
    }:
    {
      options = {
        craneLibSrcPath = lib.mkOption {
          type = lib.types.path;
          description = ''
            Source path to the directory containing the Cargo.toml root.
          '';
        };
        craneLib = lib.mkOption {
          type = lib.types.raw;
          description = ''
            A cranelib handle initialized with a nightly toolchain from fenix.
          '';
          default =
            (localFlake.inputs.crane.mkLib pkgs).overrideToolchain
              localFlake.inputs.fenix.packages.${system}.default.toolchain;
        };

        craneRustFlags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = ''
            A list of rustc compiler flags passed to `CARGO_BUILD_RUSTFLAGS` in `config.craneCtx`, but also the the exported devShell.
          '';
          # Improve default compile-times at the cost of quickly using debuggers
          # https://davidlattimore.github.io/posts/2024/02/04/speeding-up-the-rust-edit-build-run-cycle.html
          default = [
            "-C strip=debuginfo"
            "-C debuginfo=0"
          ];
        };

        craneCtx = lib.mkOption {
          type = lib.types.raw;
          description = ''
            Default arguments passed to any crane function which forwards to crane.mkCargoDerivation.
            NB: Should only be used for debug builds as it sets `CARGO_PROFILE="dev"`
          '';
        };
      };

      config = {
        craneCtx =
          let
            craneArgs = {
              strictDeps = true;
              src = config.craneLibSrcPath;
              CARGO_PROFILE = "dev";
            };
          in
          craneArgs
          // {
            # Create a reusable and cacheable derivation of just the dependencies.
            cargoArtifacts = config.craneLib.buildDepsOnly craneArgs;
            # we don't wan't to pass lints to buildDepsOnly
            CARGO_BUILD_RUSTFLAGS = (toString config.craneRustFlags);
          };
      };
    }
  );
}
