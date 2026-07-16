{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.shellAliases = {
    sudo = "sudo ";
    vi = "vim";
    ls = "eza --icons --group-directories-first --git";
    la = "ls -Ah";
    ll = "ls -lAh";
    man = "BAT_THEME='Monokai Extended' batman";
    cat = "bat";
    tree = "eza --tree --icons --git --group-directories-first";
    xdg-open = "wsl-open";
  };

  home.sessionVariables = {
    _ZO_ECHO = "1";

    # XDG compliance configurations
    WGETRC = "${config.xdg.configHome}/wgetrc";
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
    PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonstartup";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python/history";
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python";
    PYTHONUSERBASE = "${config.xdg.dataHome}/python";
    BUN_INSTALL = "${config.xdg.dataHome}/bun";
    INPUTRC = "${config.xdg.configHome}/readline/inputrc";
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    SQLITE_HISTORY = "${config.xdg.stateHome}/sqlite_history";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    GOPATH = "${config.xdg.dataHome}/go";
    GOMODCACHE = "${config.xdg.cacheHome}/go/pkg/mod";
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git .conda .mamba .direnv node_modules";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always {} | head -200'"
    ];
    fileWidgetOptions = [
      "--height 40%"
      "--border"
      "--layout=reverse"
      "--preview 'bat --color=always -n --line-range :250 {}'"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    options = [
      "--cmd z"
      "--hook pwd"
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "1337";
    };
    extraPackages = with pkgs.bat-extras; [
      batman
    ];
  };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      update_ms = 2000;
    };
  };

  xdg.configFile."yazi" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/yazi";
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "Debian_small";
        padding = {
          left = 7;
          right = 7;
          top = 2;
          bottom = 1;
        };
      };
      modules = [
        "break"
        "title"
        "separator"
        "host"
        "os"
        "kernel"
        "wm"
        "shell"
        "editor"
        {
          type = "disk";
          folders = "/";
          format = "{size-used}";
        }
        "packages"
        "uptime"
        "break"
        "colors"
        "break"
        "break"
      ];
    };
  };

  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.stateHome}/bash/history";
    historyControl = [
      "ignoreboth"
      "erasedups"
      "ignoredups"
    ];
    bashrcExtra = ''
      bind 'set bell-style none'

      if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
      fi
      if tput setaf 1 &>/dev/null; then
        PS1='$debian_chroot\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      else
        PS1='$debian_chroot\u@\h:\w\$ '
      fi
    '';
  };

  home.activation.ensureXdgDirs = lib.mkAfter ''
    run mkdir -p "${config.xdg.stateHome}/bash" \
                 "${config.xdg.stateHome}/zsh" \
                 "${config.xdg.stateHome}/python" \
                 "${config.xdg.stateHome}/node" \
                 "${config.xdg.stateHome}/less"
    run mkdir -p "${config.xdg.cacheHome}/npm"
    run mkdir -p "${config.xdg.dataHome}/npm/bin"
  '';

  xdg.configFile."wgetrc".text = ''
    hsts-file = ${config.xdg.stateHome}/wget-hsts
  '';

  xdg.configFile."python/pythonstartup".text = ''
    import sys
    if sys.version_info < (3, 13):
        import atexit
        import os
        import readline

        history = os.path.join(os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "python/history")
        try:
            os.makedirs(os.path.dirname(history), exist_ok=True)
            readline.read_history_file(history)
        except OSError:
            pass

        atexit.register(readline.write_history_file, history)
  '';
}
