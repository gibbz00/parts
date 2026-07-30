{ lib, flake-parts-lib, ... }:
{
  imports = [ ../lib.nix ];

  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    {
      options =
        let
          taploPathName = "taplo.toml";
        in
        {
          taploConfig = config.mkConfigPackageOption taploPathName ''
            [formatting]
            inline_table_expand = false
            reorder_arrays = true
            reorder_keys = true
          '';

          taploLinkHook = config.mkLinkedHookOption taploPathName config.taploConfig;
        };

      config = {
        checks =
          let
            # To avoid checking orphaned symlinks such as taplo.toml in check derivations.
            tomlFilter = name: type: type != "symlink" && lib.hasSuffix ".toml" (baseNameOf (toString name));

            taplo-derivation =
              command:
              config.craneLib.taploFmt {
                buildPhaseCargoCommand = command;
                taploExtraArgs = "--config ${config.taploConfig}";
                src = lib.cleanSourceWith {
                  src = config.craneLibSrcPath;
                  filter = tomlFilter;
                };
              };
          in
          {
            taplo-fmt = taplo-derivation "taplo format --check --diff";
            taplo-lint = taplo-derivation "taplo lint";
          };
      };
    }
  );
}
