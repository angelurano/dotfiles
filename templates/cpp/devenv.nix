{ pkgs, ... }: {
  languages.cplusplus.enable = true;
  packages = [
    pkgs.compiledb
    pkgs.valgrind
    pkgs.gdb
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

  # Run via 'devenv tasks run lsp:reload' to force generate compile_commands.json.
  tasks."lsp:reload" = {
    exec = "if [ -f Makefile ]; then compiledb -n make -B; fi";
    execIfModified = [
      "Makefile"
      "**/*.cpp"
      "**/*.hpp"
      "**/*.cc"
      "**/*.h"
    ];
  };

  git-hooks = {
    enable = true;
    hooks.clang-format.enable = true;
  };
}
