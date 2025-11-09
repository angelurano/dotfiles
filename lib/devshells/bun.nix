{ pkgs }:
{
  bunShell = { extra ? {} }:
  let
    basePkgs = with pkgs; [ bun ];
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.packages or []);

    shellHook = ''
      echo "[bun] version: $(bun -v)"
      ${extra.shellHook or ""}
    '';
  };
}

