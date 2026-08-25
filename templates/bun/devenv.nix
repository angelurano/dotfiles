{ pkgs, ... }: {
  languages.javascript = {
    enable = true;
    bun.enable = true;
    nodejs.enable = false;
    lsp.enable = false;
  };

  enterShell = ''
    if [[ $- == *i* ]]; then
      echo "[bun] version: $(bun -v)"
    fi
  '';

  git-hooks = {
    enable = true;
    hooks.prettier = {
      enable = true;
    };
  };
}
