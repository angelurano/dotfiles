{ pkgs, ... }: {
  languages.cplusplus.enable = true;
  languages.c.enable = true;
  packages = [
    # pkgs.readline
    pkgs.compiledb
  ];

  env.CXX = "g++";
  env.CLANGD_FLAGS = "--query-driver=/nix/store/**/bin/*,/usr/bin/*";
  # env.NIX_LDFLAGS = "";

  enterShell = ''
    echo "[c++] environment loaded (g++: $(g++ --version | head -n1))"
  '';

  # Run this script via 'devenv shell lsp-reload' (or 'lsp-reload' inside the shell) to generate compile_commands.json.
  # This needs to be executed during the first setup, whenever source files are added/removed, or when compiler flags change.
  scripts.lsp-reload.exec = "compiledb -n make -B";
}
