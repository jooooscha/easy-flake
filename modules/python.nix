{ pkgs, flake-utils, lib, ... }:
{
  python = {
      inputs ? []
    }:
    with pkgs;
    let
      shell = pkgs.mkShell {
        buildInputs = [
          python310
        ] ++ inputs;
        shellHook = ''
          PYTHONPATH=${python310}/${python310.sitePackages}
        '';
      };
    in flake-utils.lib.eachDefaultSystem (system: {
        devShell = shell;
    }); # end python
}
