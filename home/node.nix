{
  config,
  lib,
  ...
}:
{
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "${config.xdg.dataHome}/npm";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    npm_config_cache = "${config.xdg.cacheHome}/npm";
    NODE_REPL_HISTORY = "${config.xdg.stateHome}/node/node_repl_history";
  };

  home.sessionPath = lib.mkAfter [
    "${config.xdg.dataHome}/npm/bin"
  ];

  xdg.configFile."npm/npmrc".text = ''
    ignore-scripts=true
  '';
}
