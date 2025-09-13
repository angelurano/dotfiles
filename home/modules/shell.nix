{ config, pkgs, lib, ... }:
{
  home.shellAliases = {
    sudo = "sudo ";
    ls = "eza --icons --group-directories-first --git";
    la = "ls -Ah";
    ll = "ls -lAh";
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    options = [ "--cmd" "z" ];
  };

  home.activation.ensureXdgDirs = lib.mkAfter ''
    mkdir -p "${config.xdg.stateHome}" "${config.xdg.cacheHome}" "${config.xdg.dataHome}"
  '';
}

