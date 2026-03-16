{ pkgs, xdg }:
{
  javaShell = { jdkPackage ? pkgs.javaPackages.compiler.openjdk25, extra ? {} }:
  let
    basePkgs = [ jdkPackage ];
  in
  pkgs.mkShell {
    packages = basePkgs ++ (extra.package or []);

    shellHook = ''
      echo "[java] version: $(java -version 2>&1 | head -n 1)"

      export JAVA_HOME="${jdkPackage.home}"
      export GRADLE_USER_HOME="${xdg.dataHome}/gradle"
      ${extra.shellHook or ""}
    '';
  };
}

