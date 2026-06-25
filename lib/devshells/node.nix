{ pkgs, xdg }:
let
  mkBase =
    {
      nodePackage ? pkgs.nodejs_24,
      extra ? { },
    }:
    let
      basePkgs = [ nodePackage ];
    in
    pkgs.mkShell {
      packages = basePkgs ++ (extra.packages or [ ]);

      shellHook = ''
        echo "[node] node: $(node -v) npm: $(npm -v)"

        export NPM_CONFIG_PREFIX="${xdg.dataHome}/npm"
        export PATH="$PATH:$NPM_CONFIG_PREFIX/bin"

        export npm_config_cache="${xdg.cacheHome}/npm"

        mkdir -p "$NPM_CONFIG_PREFIX" "$npm_config_cache"

        export NPM_CONFIG_IGNORE_SCRIPTS="true"

        ${extra.shellHook or ""}
      '';
    };
in
{
  nodeShell =
    {
      nodePackage ? pkgs.nodejs_24,
      extra ? { },
    }:
    mkBase { inherit nodePackage extra; };

  nodePnpmShell =
    {
      nodePackage ? pkgs.nodejs_24,
      extra ? { },
    }:
    let
      fromExtra = extra;
    in
    mkBase {
      inherit nodePackage;

      extra = {
        packages = (with pkgs; [ pnpm ]) ++ (fromExtra.packages or [ ]);
        shellHook = ''
          export PNPM_HOME="${xdg.dataHome}/pnpm"
          export PATH="$PNPM_HOME:$PATH"
          export PNPM_CONFIG_STORE_DIR="${xdg.dataHome}/pnpm/store"

          echo "[pnpm] version: $(pnpm -v) store: $(pnpm store path 2>/dev/null || echo n/a)"
        ''
        + (fromExtra.shellHook or "");
      };
    };
}
