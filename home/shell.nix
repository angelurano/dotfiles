{ config, pkgs, lib, ... }:
{
  home.shellAliases = {
    sudo = "sudo ";
    vi = "vim";
    ls = "eza --icons --group-directories-first --git";
    la = "ls -Ah";
    ll = "ls -lAh";
    man = "BAT_THEME='Monokai Extended' batman";
    wget = "wget --hsts-file='${config.xdg.cacheHome}/wget-hsts'";
    cat = "bat";
  };

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";

    EDITOR = lib.mkDefault "nvim";
    _ZO_ECHO = "1";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

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
    defaultCommand = 
      "fd --hidden --strip-cwd-prefix --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
    changeDirWidgetCommand = 
      "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
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
    options = [ "--cmd z" "--hook pwd" ];
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

  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.stateHome}/bash/history";
    historyControl = [
      "ignoreboth" "erasedups" "ignoredups"
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
    mkdir -p "${config.xdg.stateHome}" "${config.xdg.cacheHome}" "${config.xdg.dataHome}" "${config.xdg.stateHome}/bash"
  '';
}

