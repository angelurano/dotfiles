{ pkgs, ... }: {
  languages.c.enable = true;
  packages = [
    pkgs.gnumake
    pkgs.cmake
  ];

  enterShell = ''
    echo "[c/c++] environment loaded (gcc: $(gcc --version | head -n1))"
  '';
}
