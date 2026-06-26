{ pkgs, ... }: {
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
    pnpm = {
      enable = true;
      # install.enable = true;
    };
  };

  enterShell = ''
    echo "[node] version: $(node -v)"
    echo "[pnpm] version: $(pnpm -v)"
  '';
}
