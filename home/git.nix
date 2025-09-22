{ config, pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    userEmail = "angelurano00@gmail.com";
    userName = "Miguel Angel Garcia Beltran";
    extraConfig = {
      init.defaultBranch = "main";
      core.pager = "";
    };
    aliases = {
      branches = "log --oneline --graph --decorate --all --color=always";
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

