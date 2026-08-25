{ pkgs, ... }: {
  languages.python = {
    enable = true;
    venv.enable = true;
    uv = {
      enable = true;
    };
  };

  enterShell = ''
    if [[ $- == *i* ]]; then
      echo "[python] version: $(python --version)"
      echo "[uv] version: $(uv --version)"
    fi
  '';

  git-hooks = {
    enable = true;
    hooks = {
      ruff.enable = true;
      ruff-format.enable = true;
    };
  };
}
