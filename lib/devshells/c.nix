{ pkgs }:
{
  cShell = { extra ? {} }:
  let
    basePkgs = with pkgs; [ clang gnumake pkg-config valgrind ];
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.packages or []);

    shellHook = ''
      echo "[c] gcc: $(gcc --version | head -1)"
      export NIX_CFLAGS_COMPILE+=" -Wno-unused-result ${extra.cflags or ""}"
      export NIX_LDFLAGS+=" ${extra.ldflags or ""}"
      ${extra.shellHook or ""}
    '';
  };
}

