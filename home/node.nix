{ config, pkgs, lib, ... }:
{
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "${config.xdg.dataHome}/npm";
    npm_config_cache = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
  };
  
  home.sessionPath = lib.mkAfter [
    "${config.xdg.dataHome}/npm"
  ];

  xdg.configFile."npm/npmrc".text = ''
    ignore-scripts=true
  '';
}