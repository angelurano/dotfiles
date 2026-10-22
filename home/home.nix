{ pkgs, ... }:
{
  xdg.enable = true;
  home.preferXdgDirectories = true;

  home.packages = with pkgs; [
    neovim

    # git and gh in ./git.nix via programs.git and programs.gh
    # fastfetch, fzf, bat, direnv, yazi, fd, ripgrep, jq, and oh-my-posh in ./shell.nix via programs.*
    # oh-my-zsh in ./zsh.nix via programs.zsh.oh-my-zsh
    eza
    wget
    xh
    imagemagick

    unstable.devenv
    hyperfine

    wsl-open

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
