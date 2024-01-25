# Easy DevShell Nix Flake

This flake provides simple yet somewhat configurable nix development shells.
It provides functions to enable development shells.
The goal is to only need one input for the `flake.nix`

The flake re-exports pkgs for example for python.

Currently supports:
- Rust:
  - Build using [crane](https://github.com/ipetkov/crane)
  - devshell
- Pyhton:
  - devshell

## Example

This example creates a rust `devShell` with rust nightly.

``` nix
{
  description = "Rust Dev Flake";

  inputs.easy.url = "github:jooooscha/easy-flake";

  outputs = { easy, ... }:
    easy.rust.x86_64-linux.env {
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
    easy.python.x86_64-linux.env {
      inputs = with easy.python.pkgs; [
        pylatexenc        
      ];
    };
}
```
