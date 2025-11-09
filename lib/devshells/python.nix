{ pkgs }:
{
  pythonShell = { pythonPackage ? pkgs.python314, extra ? {} }:
  let
    basePkgs =  [ pythonPackage ];
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

