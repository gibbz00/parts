localFlake:
{ ... }:
{
  imports = [
    (import ./crane.nix localFlake)
    ../lib.nix
    ./taplo.nix
    ./rustfmt.nix
    ./toolchain.nix
    ./clippy.nix
    ./doc.nix
  ];

  perSystem =
    {
      pkgs,
      config,
      system,
      ...
    }:
    {
      devShells.rust = pkgs.mkShell {
        packages =
          (with pkgs; [
            taplo
          ])
          ++ (with localFlake.inputs.fenix.packages.${system}; [
            (complete.withComponents [
              "rustc"
              "cargo"
              "clippy"
              "rustfmt"
              "rust-src"
            ])
            rust-analyzer
          ]);

        shellHook = ''
          ${config.rustfmtLinkHook}
          ${config.rustToolchainLinkHook}
          ${config.taploLinkHook}

          # Environment variables need to be set here instead since they're not merged in downstream `inputsFrom`
          export CARGO_BUILD_RUSTFLAGS="${(toString config.craneRustFlags)}";
        '';
      };
    };
}
