{ lib, flake-parts-lib, ... }:
{
  imports = [ ../lib.nix ];

  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    {
      options =
        let
          rustfmtPathName = "rustfmt.toml";
        in
        {
          rustfmtConfig = config.mkConfigPackageOption rustfmtPathName ''
            # Imports
            group_imports = "StdExternalCrate"
            imports_granularity = "Crate"

            # Comments
            comment_width = 100
            format_code_in_doc_comments = true
            wrap_comments = true

            # Code widths
            max_width = 140
            struct_lit_width = 70

            # Miscellaneous
            reorder_impl_items = true
          '';

          rustfmtLinkHook = config.mkLinkedHookOption rustfmtPathName config.rustfmtConfig;
        };

      config = {
        checks = {
          cargo-fmt = config.craneLib.cargoFmt {
            src = config.craneLibSrcPath;
            cargoExtraArgs = "--all";
            rustFmtExtraArgs = "--config-path ${config.rustfmtConfig}";
          };
        };
      };
    }
  );
}
