{
  description = "Dotfiles configuration of angelurano";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager, antigravity-nix, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    hm = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./home/home.nix

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

    mkDevShells = { pkgs, xdg ? hm.config.xdg }: import ./lib/devshells {
      inherit pkgs xdg;
    };
  in
  {
    homeConfigurations.angeldeb = hm;

    lib.mkDevShells = mkDevShells;
  };
}
