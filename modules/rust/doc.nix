{ ... }:
{
  perSystem =
    { config, ... }:
    {
      checks = {
        cargo-doc = config.craneLib.cargoDoc (
          config.craneCtx
          // {
            cargoDocExtraArgs = "--no-deps --all-features --workspace --document-private-items";
            env.RUSTDOCFLAGS = "--deny warnings";
          }
        );
      };
    };
}
