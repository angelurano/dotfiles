{ pkgs, xdg }:
{
  cShell = { extra ? {} }:
  let
    basePkgs = with pkgs; [ gcc gnumake pkg-config valgrind ];
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.packages or []);

    shellHook = ''
      echo "[c] gcc: $(gcc --version | head -1)"

      export CC=gcc
      export CXX=g++

      export NIX_CFLAGS_COMPILE+=" -Wno-unused-result -Wno-deprecated-non-prototype ${extra.cflags or ""}"
      export NIX_LDFLAGS+=" ${extra.ldflags or ""}"
      ${extra.shellHook or ""}
    '';
  };
}

