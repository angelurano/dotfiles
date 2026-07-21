{
  description = "angelurano's dotfiles configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix/7fd0df73b864c2e385f625df06545c5b3868f057";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      # self,
      nixpkgs,
      home-manager,
      antigravity-nix,
      nix-index-database,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

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

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          antigravity-cli = antigravity-nix.packages.${system}.google-antigravity-cli;
        };
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
