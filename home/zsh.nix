{
  config,
  pkgs,
  lib,
  ...
}:
{

  xdg.configFile."ohmyposh/conf.toml".source = ../config/ohmyposh/conf.toml;

  programs.zsh = {
    enable = true;

    dotDir = "${config.xdg.configHome}/zsh"; # ".config/zsh";

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "";
      extraConfig = ''
        export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump-$HOST-$ZSH_VERSION"
        export HIST_STAMPS="dd/mm/yyyy"
      '';
    };

    initContent = lib.mkOrder 1500 ''
      unsetopt BEEP
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${config.xdg.configHome}/ohmyposh/conf.toml)"

      command_not_found_handler() {
        local cmd="$1"
        shift

        trap 'return 130' INT

        print -P "Command '$cmd' not found"

        local nix_packages=()
        if (( $+commands[nix-locate] )); then
          local raw_matches
          raw_matches=$(nix-locate --minimal --no-group --type x --type s --whole-name --at-root "/bin/$cmd" 2>/dev/null)
          if [[ -n "$raw_matches" ]]; then
            nix_packages=(''${(f)"$(echo "$raw_matches" | sed -E 's/\.[^.]+$//' | sort -u)"})
          fi
        fi

        if (( ''${#nix_packages[@]} > 0 )); then
          print -P "  %F{blue}Nix (run with comma):%f"
          print -P "    , $cmd"
          print -P "  %F{blue}Nix Shell (Flakes):%f"
          local count=0
          for pkg in "''${nix_packages[@]}"; do
            if (( count < 5 )); then
              print -P "    nix shell nixpkgs#$pkg"
            fi
            (( count++ ))
          done
          if (( count > 5 )); then
            print -P "    %F{242}... (and $(( count - 5 )) more packages)%f"
          fi
        fi

        if (( $+commands[apt-cache] )); then
          if apt-cache show "$cmd" &>/dev/null; then
            print -P "  %F{yellow}Debian (APT):%f"
            print -P "    sudo apt install $cmd"
          fi
        fi

        return 127
      }
    '';

    loginExtra = ''
      _state_dir="''${XDG_RUNTIME_DIR:-/tmp/user-runtime-$UID}/zlogin-fastfetch"
      mkdir -p -- "$_state_dir"
      if [ ! -e "$_state_dir/once" ]; then
        command -v fastfetch >/dev/null 2>&1 && fastfetch
        : >| "$_state_dir/once"
      fi
    '';
  };
}
