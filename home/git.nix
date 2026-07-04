{
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "angelurano00@gmail.com";
        name = "Miguel Angel Garcia Beltran";
      };
      alias = {
        branches = "log --oneline --graph --decorate --all --color=always";
      };
      init = {
        defaultBranch = "main";
      };
      color.ui = "auto";
      core.pager = "";
    };
    ignores = [
      ".direnv"
      ".devenv"

      ".pre-commit-config.yaml"

      ".envrc"
      "flake.nix"
      "flake.lock"
      "devenv.nix"
      "devenv.lock"
      "devenv.yaml"
      # git add --intent-to-add -f flake.nix flake.lock && \
      # git update-index --assume-unchanged flake.nix flake.lock
    ];
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}
