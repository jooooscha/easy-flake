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
            , root
          }:
          with pkgs;
          let 

            # All inputs

            rustStable-input = optional stable (rust-bin.stable.latest.default.override {
              extensions = [ "rust-src" ] ++ extensions;
              targets = targets;
            });
            rustNightly-input = optional nightly (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default));

            rust-default-inputs = with pkgs; [
                cargo-edit
                cargo-expand
                cargo-outdated
                cargo-watch
            ];

            # Shell

            rust-shell = pkgs.mkShell {
              buildInputs = rust-default-inputs ++ inputs
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

            rust-package = naersk-lib.buildPackage {
              pname = "${name}";
              root = root;
              buildInputs = with pkgs; [ openssl pkgconfig xorg.libxcb python310 ];
              nativeBuildInputs = with pkgs; [ openssl pkgconfig xorg.libxcb python310 ];
            };

          in flake-utils.lib.eachDefaultSystem (system: {
            packages."${name}" = rust-package;
            defaultpackage = packages."${name}";
            devShell = rust-shell;
          }); # end rust
      }; # end output set
}
