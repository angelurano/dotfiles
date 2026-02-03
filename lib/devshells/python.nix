{ pkgs }:
{
  pythonShell = { pythonPackage ? pkgs.python314, extra ? {} }:
  let
    basePkgs =  [ pythonPackage ] ++ (with pkgs; [ uv ]);
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.packages or []);

    shellHook = ''
      alias python="python3"
      echo "[python] version $(python --version)"

      ${extra.shellHook or ""}
    '';
  };
}

