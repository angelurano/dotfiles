{ pkgs, ... }: {
  packages = [ pkgs.bun ];

  enterShell = ''
    echo "[bun] version: $(bun -v)"
  '';
}
