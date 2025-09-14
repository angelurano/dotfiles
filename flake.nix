{
  description = "Home Manager configuration of angeldeb";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations.angeldeb = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home/home.nix

          ./home/shell.nix
          ./home/zsh.nix
          ./home/git.nix
          ./home/nvim.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        # extraSpecialArgs = { inherit system; };
      };
    };
}
