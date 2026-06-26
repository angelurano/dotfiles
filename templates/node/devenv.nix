{ pkgs, ... }: {
  languages.javascript.enable = true;
  languages.javascript.package = pkgs.nodejs_22;

  enterShell = ''
    echo "[node] version: $(node -v)"
  '';
}
