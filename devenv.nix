{ pkgs, ... }: {
  packages = [ pkgs.nixfmt ];

  git-hooks.hooks.nixfmt.enable = true;
}
