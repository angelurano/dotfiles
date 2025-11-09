{ pkgs }:
let
  mkBase = { nodePackage ? pkgs.nodejs_24, extra ? {} }:
  let
    basePkgs = [ nodePackage ];
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.packages or []);

    shellHook = ''
      echo "[node] node: $(node -v) npm: $(npm -v)"
      export npm_config_cache="$XDG_CACHE_HOME/npm"

      ${extra.shellHook or ""}
    '';
  };
in
{
  nodeShell = { nodePackage ? pkgs.nodejs_24, extra ? {} }:
    mkBase { inherit nodePackage extra; };

  nodePnpmShell = { nodePackage ? pkgs.nodejs_24, extra ? {} }:
  let
    fromExtra = extra;
  in
  mkBase {
    inherit nodePackage;

    extra = {
      packages = (with pkgs; [ pnpm ]) ++ (fromExtra.packages or []);
      shellHook = ''
        export PNPM_HOME="$XDG_DATA_HOME/pnpm"
        export PATH="$PNPM_HOME:$PATH"

        _want_store="$XDG_DATA_HOME/pnpm/store"
        _cur_store="$(pnpm store path 2>/dev/null || true)"
        if [ -n "$_want_store" ] && [ "$_cur_store" != "$_want_store" ]; then
          mkdir -p "$_want_store"
          pnpm config set store-dir "$_want_store" --global >/dev/null 2>&1 || true
        fi

        echo "[pnpm] version: $(pnpm -v) store: $(pnpm store path 2>/dev/null || echo n/a)"
	'' + (fromExtra.shellHook or "");
    };
  };
}
