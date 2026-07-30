{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      options = {
        mkConfigPackageOption = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
          description = ''
            Create a configuration package for a given path and its corresponding config text.
          '';
          default =
            path: text:
            lib.mkOption {
              type = lib.types.raw;
              default = pkgs.writeText path text;
              description = ''
                Shared configuration for ${path}.
              '';
            };
        };

        mkLinkedHookOption = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
          description = ''
            Create a bash snippet option for installing a package's content in a link shell hook.
          '';
          default =
            path: configPackage:
            lib.mkOption {
              type = lib.types.str;
              description = ''
                Bash snippet for for linking ${path} to the project within as a shell hook.
              '';
              default = ''
                _work_dir="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
                _final_path="''${_work_dir}/${path}"

                # Check before write to avoid excessive filesystem churn
                if [[ $(readlink "$_final_path") != ${configPackage} ]]; then
                  [ -L "$_final_path" ] && unlink "$_final_path"

                  if [ -e "$_final_path" ]; then
                    echo 1>&2 "base.nix: WARNING: Refusing to install because of an existing config at ${path}"
                  else
                    echo 1>&2 "base.nix: installing ${path}"
                    ln -fs ${configPackage} "$_final_path"
                  fi
                fi
              '';
            };
        };
      };
    }
  );
}
