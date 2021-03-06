# Easy DevShell Nix Flake

This flake provides simple yet somewhat configurable nix development shells.
It provides functions to enable development shells.
The goal is to only need one input for the `flake.nix`

The flake re-exports pkgs for example for python.

## Example

This example creates a rust `devShell` with rust nightly.

``` nix
{
  description = "Rust Dev Flake";

  inputs.easy.url = "github:jooooscha/easy-flake";

  outputs = { easy, ... }:
    easy.rust.env {
      nightly = true;
    };
}
```

This example shows an example with pyhton

``` nix
{
  description = "Python Dev Flake";

  inputs.easy.url = "github:jooooscha/easy-flake";

  outputs = { easy, ... }:
    easy.python.env {
      inputs = with easy.python.pkgs; [
        pylatexenc        
      ];
    };
}
```
