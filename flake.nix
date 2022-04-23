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
      , hook ? ""
      , inputs ? []
    }:
      flake-utils.lib.eachDefaultSystem (system: {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            cargo-edit
            cargo-expand
            cargo-outdated
            cargo-watch
          ] ++ inputs
            ++ optionals ssl [ pkgconfig openssl ]
            ++ optional nightly rust-bin.nightly.latest.default
            ++ optional stable rust-bin.stable.latest.default;
          shellHook = hook;
        };
      });
  };
}
        # options.rust = {
        #   enable = mkEnableOption "Enable rust environment";
        # };

        # config = mkIf cfg.enable {
        #   outputs.devShell.x86_64-linux = pkgs.mkShell {
        #     shellHook = "echo hiiiii";
        #   };
        # };

        # config = mkIf cfg.enable {
        #   devShell.x86_64-linux = pkgs.mkShell {
        #     shellHook = "echo works";
        #     buildInputs = with pkgs; [
        #       rust-bin.stable.latest.default
        #         cargo-edit
        #         cargo-expand
        #         cargo-outdated
        #         cargo-watch
        #         lldb
        #         rust-analyzer

        #         nixpkgs-fmt

        #         pkgconfig
        #         openssl
        #     ];
        #   };
        # };
  # };
# }
