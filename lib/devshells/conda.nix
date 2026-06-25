{ pkgs, xdg }:
{
  condaShell =
    {
      envName ? "main",
      pythonVersion ? "3.13",
      condaPackages ? [ ], # ["numpy" "pandas"]
      extra ? { },
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
      packages = basePkgs ++ (extra.packages or [ ]);

      shellHook = ''
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath systemLibs}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

        export MAMBA_EXTRACT_THREADS=1

        export MAMBA_ROOT_PREFIX="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/.mamba"

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

        _env_name="${envName}"
        if [ "$_env_name" = "main" ]; then
          _env_name="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"
        fi

        if [ ! -d "$MAMBA_ROOT_PREFIX/envs/$_env_name" ]; then
          echo "[mamba] Creating environment '$_env_name'..."
          micromamba create -n "$_env_name" python=${pythonVersion} ${packagesString} -c conda-forge -y
        fi

        micromamba activate "$_env_name"

        ${extra.shellHook or ""}
      '';
    };
}
