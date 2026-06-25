{
  pkgs,
  xdg ? null,
}:
let
  args = {
    inherit pkgs;

    xdg =
      if xdg != null then
        xdg
      else
        {
          cacheHome = "$HOME/.cache";
          configHome = "$HOME/.config";
          dataHome = "$HOME/.local/share";
          stateHome = "$HOME/.local/state";
        };
  };
in
{
  cShell = (import ./c.nix args).cShell;
  cppShell = (import ./cpp.nix args).cppShell;
  nodeShell = (import ./node.nix args).nodeShell;
  nodePnpmShell = (import ./node.nix args).nodePnpmShell;
  bunShell = (import ./bun.nix args).bunShell;
  pythonShell = (import ./python.nix args).pythonShell;
  uvShell = (import ./python.nix args).uvShell;
  condaShell = (import ./conda.nix args).condaShell;
  javaShell = (import ./java.nix args).javaShell;
}
