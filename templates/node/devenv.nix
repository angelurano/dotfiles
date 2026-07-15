{ pkgs, ... }: {
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
    pnpm = {
      enable = true;
    };
  };

  enterShell = ''
    if [[ $- == *i* ]]; then
      echo "[node] version: $(node -v)"
      echo "[pnpm] version: $(pnpm -v)"
    fi
  '';

  git-hooks = {
    enable = true;
    hooks.prettier = {
      enable = true;
    };
  };
}
