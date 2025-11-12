{ config, pkgs, lib, ... }:
{

  xdg.configFile."ohmyposh/conf.toml".source = ../config/ohmyposh/conf.toml;

  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";# "${config.xdg.configHome}/zsh";

    enableCompletion = true;
    autosuggestion.enable = true;

    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "fzf" "zoxide" ];
      theme = "";
      extraConfig = ''
        export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump-$HOST-$ZSH_VERSION"
        export HIST_STAMPS="dd/mm/yyyy"
      '';
    };

    initContent = lib.mkOrder 1500 ''
      unsetopt BEEP
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${config.xdg.configHome}/ohmyposh/conf.toml)"
    '';

    loginExtra = ''
      _state_dir="$XDG_RUNTIME_DIR/zlogin-fastfetch"
      mkdir -p -- "$_state_dir"
      if [ ! -e "$_state_dir/once" ]; then
        command -v fastfetch >/dev/null 2>&1 && fastfetch
        : >| "$_state_dir/once"
      fi
    '';
  };
}

