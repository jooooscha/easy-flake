{ pkgs, flake-utils, lib, ... }:
{
  rust = { nightly ? false
      , stable ? true
      , ssl ? false
      , inputs ? []
      , lsp ? true
      , targets ? []
      , extensions ? []
      , name ? "no-name-given"
      , root ? ./.
    }:
    with pkgs;
    with lib;
    let

      rustStable-input = optional stable (rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ] ++ extensions;
          targets = targets;
          });

      rustNightly-input = optional nightly (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override { extensions = [ "rust-src" ] ++ extensions; } ));

      default-inputs = with pkgs; [
        cargo-edit
        cargo-expand
        cargo-outdated
        cargo-watch
      ];

      shell = pkgs.mkShell {
        buildInputs = default-inputs ++ inputs
          ++ optionals ssl     [ pkgconfig openssl ]
          ++ optional  lsp     rust-analyzer
          ++ rustNightly-input
          ++ rustStable-input;
        shellHook = ''
          echo ""
          echo " *** Rust Dev Shell ***"
          echo ""
          echo "   - stable:   ${ boolToString stable }"
          echo "   - nightly:  ${ boolToString nightly }"
          echo "   - lsp:      ${ boolToString lsp }"
          echo "   - ssl:      ${ boolToString ssl }"
          echo "   - name:     ${ name }"
          echo ""
          '';
      };

      package = naersk-lib.buildPackage {
        pname = "${name}";
        root = root;
        buildInputs = with pkgs; [ openssl pkgconfig xorg.libxcb python310 ];
        nativeBuildInputs = with pkgs; [ openssl pkgconfig xorg.libxcb python310 ];
      };

    in flake-utils.lib.eachDefaultSystem (system: rec {
        packages."${name}" = package;
        defaultPackage = packages."${name}";
        devShell = shell;
        # formatter = rust-formatter;
    });
}
