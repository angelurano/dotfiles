{ pkgs, ... }: {
  languages.c.enable = true;
  packages = [
    pkgs.gcc
    pkgs.gnumake
  ];

  env.CC = "gcc";
  env.NIX_CFLAGS_COMPILE = "-Wno-unused-result"; # -Wno-deprecated-non-prototype
  # env.NIX_LDFLAGS = "";

  enterShell = ''
    echo "[c/c++] environment loaded (gcc: $(gcc --version | head -n1))"
  '';
}
