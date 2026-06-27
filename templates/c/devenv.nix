{ pkgs, ... }: {
  languages.c.enable = true;
  packages = [
    # pkgs.readline
    # pkgs.libX11
    # pkgs.libxext
    # pkgs.libxrender
    # pkgs.libbsd
    # pkgs.libxfixes
  ];

  env.CC = "gcc";
  env.NIX_CFLAGS_COMPILE = "-Wno-unused-result -Wno-deprecated-non-prototype"; # -std=gnu17";
  # env.NIX_LDFLAGS = "";

  enterShell = ''
    echo "[c] environment loaded (gcc: $(gcc --version | head -n1))"
  '';
}
