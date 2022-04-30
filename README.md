# Easy DevShell Nix Flake

This flake provides simple yet somewhat configurable nix development shells.
It provides functions to enable development shells.
The goal is to only need one input for the `flake.nix`

## Example

This example creates a rust `devShell` with rust nightly.

``` nix
{
  description = "Rust Dev Flake";

  inputs.easy.url = "github:jooooscha/easy-flake";

  outputs = { easy, nixpkgs, ... }:
    easy.rust { nightly = true; };
}
```
