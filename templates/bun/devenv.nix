{ pkgs, ... }: {
  languages.javascript = {
    enable = true;
    bun = {
      enable = true;
      # install.enable = true;
    };
  };

  enterShell = ''
    echo "[bun] version: $(bun -v)"
  '';
}
