localFlake:
{ pkgs, ... }:
{
  imports = [
    localFlake.inputs.git-hooks.flakeModule
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      devShells.pre-commit = pkgs.mkShell {
        inherit (config.pre-commit) shellHook;
        packages = config.pre-commit.settings.enabledPackages;
      };

      pre-commit = {
        settings.hooks = {
          nixfmt.enable = true;
          typos.enable = true;

          check-yaml.enable = true;
          check-json.enable = true;
          check-xml.enable = true;
          check-toml.enable = true;

          convco.enable = true;
          check-merge-conflicts.enable = true;
          forbid-new-submodules.enable = true;

          check-executables-have-shebangs.enable = true;
          end-of-file-fixer.enable = true;
          trim-trailing-whitespace.enable = true;
        };
      };
    };
}
