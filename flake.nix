{
  description = "Easy flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  
  outputs = { self, flake-utils, nixpkgs, rust-overlay }: {
    
    rust = { config, lib, nixpkgs, rust-overlay, ... }:
      with lib;
      let
        cfg = config.easy-flake.rust;

        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlay ];
        };


      in {

        options.easy-flake.rust.enable = mkEnableOption "Enables the rust environment";

        config = mkIf cfg.enable {
            devShell.${system} = (({ pkgs, ... }:
              pkgs.mkShell {
                  buildInputs = with pkgs; [
                    pkgconfig
                    openssl
                    cargo
                    cargo-watch
                    nodejs
                    wasm-pack
                    nodePackages.webpack-cli
                    nodePackages.serve
                    (rust-bin.stable.latest.default.override {
                     extensions = [ "rust-src" ];
                     targets = [ "wasm32-unknown-unknown" ];
                     })
                  ];

                  shellHook = "";
              }) {
                pkgs = pkgs;
              });
          };
      };
  };
}
