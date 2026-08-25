{ pkgs, ... }:
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
    xh
    jq

    unstable.devenv
    direnv
    hyperfine

    yazi
    wsl-open

    oh-my-posh
    oh-my-zsh

    nodejs_24
    python314

    (writeShellScriptBin "xdg-open" ''
      exec wsl-open "$@"
    '')

    nil
    nixfmt

    unstable.herdr

    llm-pkgs.antigravity-cli
    llm-pkgs.opencode
  ];

  home.sessionVariables = {
    BROWSER = "brave";
  };

  home.file.".ignore".text = ''
    .conda/
    .mamba/
    micromamba/
    env/
    venv/

    .direnv/

    .devenv/
    .direnv/devenv-profile*
    nix/
    .nix-mix/
    .nix-profile/
  '';

  programs.home-manager.enable = true;

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = false;
  };

  programs.nix-index-database.comma.enable = true;
}
