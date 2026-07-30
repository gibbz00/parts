{ ... }:
{
  perSystem =
    { config, ... }:
    {
      # WORKAROUND: can't find a way to declare *rust* lints in a file outside
      # of Cargo.toml. Clippy lints have a `clippy.toml`, but it may be
      # deprecated in the future.
      craneRustFlags = [
        "-D unused-must-use"
        "-W missing-docs"
        "-W clippy::self-named-module-files"
      ];

      checks = {
        cargo-clippy = config.craneLib.cargoClippy (
          config.craneCtx // { cargoClippyExtraArgs = "--all-targets -- --deny warnings"; }
        );
      };
    };
}
