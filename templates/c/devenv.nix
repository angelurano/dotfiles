{ pkgs, ... }: {
  languages.c.enable = true;
  packages = [
    pkgs.compiledb
    # pkgs.readline
    # pkgs.libX11
    # pkgs.libxext
    # pkgs.libxrender
    # pkgs.libbsd
    # pkgs.libxfixes
  ];

  env.CC = "gcc";
  env.NIX_CFLAGS_COMPILE = "-Wno-unused-result -Wno-deprecated-non-prototype"; # -std=gnu17";
  env.CLANGD_FLAGS = "--query-driver=/nix/store/**/bin/*,/usr/bin/*";
  # env.NIX_LDFLAGS = "";

  enterShell = ''
    echo "[c] environment loaded (gcc: $(gcc --version | head -n1))"
  '';

  # Run this script via 'devenv shell lsp-reload' (or 'lsp-reload' inside the shell) to generate compile_commands.json.
  # This needs to be executed during the first setup, whenever source files are added/removed, or when compiler flags change.
  scripts.lsp-reload.exec = "compiledb -n make -B";
}
