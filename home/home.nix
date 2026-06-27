{
  config,
  pkgs,
  lib,
  antigravity-cli,
  ...
}:
{
  xdg.enable = true;
  home.preferXdgDirectories = true;

  home.packages = with pkgs; [
    git
    gh

    neovim

    fastfetch
    ripgrep
    fd
    fzf
    eza
    bat
    wget
    direnv
    devenv

    yazi
    wsl-open

    antigravity-cli

    oh-my-posh
    oh-my-zsh

    nodejs_22

    (writeShellScriptBin "xdg-open" ''
      exec wsl-open "$@"
    '')
  ];

  home.sessionVariables = {
    BROWSER = "brave";
  };

  programs.home-manager.enable = true;
}
