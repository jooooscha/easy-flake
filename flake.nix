{
  description = "Easy flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, flake-utils, nixpkgs, rust-overlay, naersk }:
      with nixpkgs.lib;
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlay ];
        };
        naersk-lib = naersk.lib.${system};
      in {
        pkgs = pkgs;

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
          let 

            # All inputs

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

            # Shell

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

            # Nix build package

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
          }); # end rust

          python-packages = pkgs.python310Packages;
          python = { inputs ? [] }:
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
            in flake-utils.lib.eachDefaultSystem (system: rec {
              devShell = shell;
            }); # end python

      }; # end output set
}
