{
  description = "Easy flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, flake-utils, nixpkgs, rust-overlay }:
  with nixpkgs.lib;
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ rust-overlay.overlay ];
    };

  in {
    rust = { nightly ? false
      , stable ? true
      , ssl ? false
      , inputs ? []
      , lsp ? true
    }:
    let 
      rustStable = optional stable pkgs.rust-bin.stable.latest.default;
      rustNightly = optional nightly (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default));
    in flake-utils.lib.eachDefaultSystem (system: {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            cargo-edit
            cargo-expand
            cargo-outdated
            cargo-watch
          ] ++ inputs
            ++ optionals ssl     [ pkgconfig openssl ]
            ++ optional  lsp     rust-analyzer
            ++ rustNightly
            ++ rustStable;
          shellHook = ''
            echo ""
            echo " *** Rust Dev Shell ***"
            echo ""
            echo "   - stable:   ${ boolToString stable}"
            echo "   - nightly:  ${ boolToString nightly}"
            echo "   - lsp:      ${ boolToString lsp}"
            echo "   - ssl:      ${ boolToString ssl}"
            echo ""
          '';
        };
      });
  };
}
