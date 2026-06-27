{ pkgs, ... }: {
  languages.cplusplus.enable = true;
  languages.c.enable = true;
  packages = [
    # pkgs.readline
  ];

  env.CXX = "g++";
  # env.NIX_LDFLAGS = "";

  enterShell = ''
    echo "[c++] environment loaded (g++: $(g++ --version | head -n1))"
  '';
}
