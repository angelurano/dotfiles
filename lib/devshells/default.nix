{ pkgs, xdg ? null }:
let
  args = {
    inherit pkgs;

    xdg = if xdg != null then xdg else {
      cacheHome = "$HOME/.cache";
      configHome = "$HOME/.config";
      dataHome = "$HOME/.local/share";
      stateHome = "$HOME/.local/state";
    };
  };
in
  (import ./c.nix args) //
  (import ./cpp.nix args) //
  (import ./node.nix args) //
  (import ./bun.nix args) //
  (import ./python.nix args) //
  (import ./conda.nix args)

