{ pkgs }:
  (import ./c.nix { inherit pkgs; })
  // (import ./cpp.nix { inherit pkgs; })
  // (import ./node.nix { inherit pkgs; })
  // (import ./bun.nix { inherit pkgs; })
  // (import ./python.nix { inherit pkgs; })

