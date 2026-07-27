{
  description = "angelurano's dotfiles configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      # self,
      nixpkgs,
      home-manager,
      nixpkgs-unstable,
      llm-agents,
      nix-index-database,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            unstable = pkgs-unstable;
            llm-pkgs = llm-agents.packages.${system};
          })
        ];
      };

      hm = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          nix-index-database.homeModules.nix-index

          ./home/home.nix
          {
            home.username = "angeldeb";
            home.homeDirectory = "/home/angeldeb";
            home.stateVersion = "26.05";
          }

          ./home/shell.nix
          ./home/zsh.nix
          ./home/git.nix
          ./home/nvim.nix
          ./home/node.nix
        ];
      };

    in
    {
      homeConfigurations.angeldeb = hm;

      templates = {
        bun = {
          path = ./templates/bun;
          description = "Bun development environment (Devenv)";
        };
        c = {
          path = ./templates/c;
          description = "C development environment (Devenv)";
        };
        cpp = {
          path = ./templates/cpp;
          description = "C++ development environment (Devenv)";
        };
        python = {
          path = ./templates/python;
          description = "Python development environment (Devenv)";
        };
        node = {
          path = ./templates/node;
          description = "Node.js development environment (Devenv)";
        };
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
