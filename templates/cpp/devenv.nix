{ pkgs, ... }: {
  languages.cplusplus.enable = true;
  languages.c.enable = true;
  packages = [
    pkgs.compiledb
  ];

  env.CXX = "g++";
  env.CLANGD_FLAGS = "--query-driver=/nix/store/**/bin/*,/usr/bin/*";

  enterShell = ''
    if [[ $- == *i* ]]; then
      echo "[c++] environment loaded (g++: $(g++ --version | head -n1))"
      if [ -f Makefile ]; then
        if [ ! -f compile_commands.json ] || [ Makefile -nt compile_commands.json ]; then
          if ! pgrep -f "compiledb -n make" >/dev/null; then
            (compiledb -n make -B >/dev/null 2>&1 &)
          fi
        fi
      fi
    fi
  '';

  # Run this script via 'devenv shell lsp-reload' (or 'lsp-reload' inside the shell) to generate compile_commands.json.
  scripts.lsp-reload.exec = "compiledb -n make -B";

  git-hooks = {
    enable = true;
    hooks.clang-format.enable = true;
  };
}
