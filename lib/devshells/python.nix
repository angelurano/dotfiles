{ pkgs, xdg }:
let
  mkBase = { pythonPackage ? pkgs.python313, extra ? {} }:
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

      export PYTHON_HISTORY="${xdg.stateHome}/python_history"
      export PYTHONPYCACHEPREFIX="${xdg.cacheHome}/python"
      export PYTHONUSERBASE="${xdg.dataHome}/python"

      export JUPYTER_CONFIG_DIR="${xdg.configHome}"/jupyter
      export JUPYTER_PLATFORM_DIRS="1"

      export IPYTHONDIR="${xdg.configHome}/ipython"
      ${extra.shellHook or ""}
    '';
  };
in
{
  pythonShell = { pythonPackage ? pkgs.python313, extra ? {} }:
    mkBase { inherit pythonPackage extra; };

  uvShell = { pythonPackage ? pkgs.python313, extra ? {} }:
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

        export UV_CACHE_DIR="${xdg.cacheHome}/uv"
      '' + (fromExtra.shellHook or "");
    };
  };
}
