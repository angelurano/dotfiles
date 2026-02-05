{ pkgs }:
let
  mkBase = { pythonPackage ? pkgs.python311, extra ? {} }:
  let
    systemLibs = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      glib
    ];
    basePkgs = [ pythonPackage ] ++ systemLibs;
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.packages or []);

    env = {
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath systemLibs;
    };

    shellHook = ''
      echo "[python] $(python --version)"
      ${extra.shellHook or ""}
    '';
  };
in
{
  pythonShell = { pythonPackage ? pkgs.python311, extra ? {} }:
    mkBase { inherit pythonPackage extra; };

  uvShell = { pythonPackage ? pkgs.python311, extra ? {} }:
  let
    fromExtra = extra;
  in
  mkBase {
    inherit pythonPackage;
    extra = {
      packages = [ pkgs.uv ] ++ (fromExtra.packages or []);
      shellHook = ''
        echo "[uv] $(uv --version)"
        # use 'uv venv'/'uv sync'
      '' + (fromExtra.shellHook or "");
    };
  };
}
