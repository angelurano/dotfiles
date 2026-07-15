{ pkgs, ... }: {
  languages.javascript = {
    enable = true;
    bun = {
      enable = true;
    };
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
