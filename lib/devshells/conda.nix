{ pkgs, xdg }:
{
  condaShell = {
    envName ? "main",
    pythonVersion ? "3.13",
    condaPackages ? [], # ["numpy" "pandas"]
    extra ? {}
  }:
  let
    systemLibs = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      glib
    ];

    # ["a" "b"] -> "a b"
    packagesString = builtins.concatStringsSep " " condaPackages;

    basePkgs = [ pkgs.micromamba ] ++ systemLibs;
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.packages or []);

    env = {
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath systemLibs;
    };

    shellHook = ''
      export MAMBA_EXTRACT_THREADS=1

      export MAMBA_ROOT_PREFIX="$PWD/.mamba"

      export CONDA_PKGS_DIRS="${xdg.cacheHome}/mamba/pkgs"
      mkdir -p "$CONDA_PKGS_DIRS"

      # Python
      export PYTHON_HISTORY="${xdg.stateHome}/python_history"
      export PYTHONPYCACHEPREFIX="${xdg.cacheHome}/python"
      export PYTHONUSERBASE="${xdg.dataHome}/python"
      export JUPYTER_CONFIG_DIR="${xdg.configHome}"/jupyter
      export JUPYTER_PLATFORM_DIRS="1"
      export IPYTHONDIR="${xdg.configHome}/ipython"

      eval "$(${pkgs.micromamba}/bin/micromamba shell hook --shell bash)"

      export CONDA_CHANNELS="conda-forge"

      if [ ! -d "$MAMBA_ROOT_PREFIX/envs/${envName}" ]; then
        echo "[mamba] Creating environment '${envName}'..."
        micromamba create -n "${envName}" python=${pythonVersion} ${packagesString} -c conda-forge -y
      fi

      micromamba activate "${envName}"

      ${extra.shellHook or ""}
    '';
  };
}
