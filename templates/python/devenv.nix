{ pkgs, ... }: {
  languages.python = {
    # version = "3.13.13";
    enable = true;
    venv.enable = true;
    uv = {
      enable = true;
      # sync.enable = true;
    };
  };

  packages = [
    # pkgs.python3Packages.numpy
  ];

  enterShell = ''
    echo "[python] version: $(python --version)"
    echo "[uv] version: $(uv --version)"
  '';
}
