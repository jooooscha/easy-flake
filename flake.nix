{
  description = "Easy flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # naersk.url = "github:nix-community/naersk";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, nixpkgs, rust-overlay, crane }:
    with nixpkgs.lib;
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          rust-overlay.overlay
          ( self: super: {
            python = super.python310Packages; 
          })
        ];
      };
      # naersk-lib = naersk.lib.${system};
      craneLib = crane.lib.${system};
      rust-module = import ./modules/rust.nix { inherit pkgs flake-utils craneLib; lib = pkgs.lib; };
      python-module = import ./modules/python.nix { inherit pkgs flake-utils; lib = pkgs.lib; };
    in {
      pkgs = pkgs;

      rust = {
        env = rust-module.rust;
      };

      python = {
        env = python-module.python;
        pkgs = pkgs.python310Packages;
      };

      shell = { shell }:
        flake-utils.lib.eachDefaultSystem (system: {
            devShell = import shell { inherit pkgs; };
        }); # end shell
    }; # end output-set
}
