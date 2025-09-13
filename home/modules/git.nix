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
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}

