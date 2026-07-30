{ lib, flake-parts-lib, ... }:
{
  imports = [ ../lib.nix ];

  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    {
      options =
        let
          rustToolchainPathName = "rust-toolchain.toml";
        in
        {
          rustToolchain = config.mkConfigPackageOption rustToolchainPathName ''
            [toolchain]
            channel = "nightly"
          '';

          rustToolchainLinkHook = config.mkLinkedHookOption rustToolchainPathName config.rustToolchain;
        };
    }
  );
}
