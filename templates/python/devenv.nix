{ pkgs, ... }: {
  languages.python.enable = true;

  enterShell = ''
    echo "[python] version: $(python --version)"
  '';
}
