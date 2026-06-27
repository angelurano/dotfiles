{
  description = "angelurano's dotfiles configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix/v2.0.0-6324554176528384";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      antigravity-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      hm = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home/home.nix
          {
            home.username = "angeldeb";
            home.homeDirectory = "/home/angeldeb";
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
          description = "C/C++ development environment (Devenv)";
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
