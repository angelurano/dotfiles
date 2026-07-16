{
  pkgs,
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
    xh

    direnv
    devenv
    hyperfine

    yazi
    wsl-open

    antigravity-cli

    oh-my-posh
    oh-my-zsh

    nodejs_24
    python314

    (writeShellScriptBin "xdg-open" ''
      exec wsl-open "$@"
    '')

    nil
    nixfmt
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
    enableZshIntegration = true;
  };

  programs.nix-index-database.comma.enable = true;
}
