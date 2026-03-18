{ config, pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "angelurano00@gmail.com";
        name = "Miguel Angel Garcia Beltran";
      };
      alias = {
        branches = "log --oneline --graph --decorate --all --color=always";
      };
      init = {
        defaultBranch = "main";
      };
      core.pager = "";
    };
    ignores = [
      "flake.nix" "flake.log" ".envrc" ".direnv"
      # git add --intent-to-add -f flake.nix flake.lock && \
      # git update-index --assume-unchanged flake.nix flake.lock
    ];
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}

