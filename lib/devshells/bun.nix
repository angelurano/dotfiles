{ pkgs, xdg }:
{
  bunShell = { extra ? {} }:
  let
    basePkgs = with pkgs; [ bun ];
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.packages or []);

    shellHook = ''
      export BUN_INSTALL="${xdg.dataHome}/bun"

      echo "[bun] version: $(bun -v)"

      ${extra.shellHook or ""}
    '';
  };
}

