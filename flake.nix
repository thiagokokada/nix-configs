{
  description = "My Nix{OS} configuration files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home.url = "github:nix-community/home-manager/release-20.09";
    emacs.url = "github:nix-community/emacs-overlay/e3da699893c4be3b946d3586143b03450f9680ee";
  };

  outputs = { self, nixpkgs, unstable, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules =
        [
          ./nixos/cli.nix
          ./nixos/desktop.nix
          ./nixos/dev.nix
          ./nixos/game.nix
          ./nixos/misc.nix
          ./nixos/xserver.nix
          ./overlays
        ];
      specialArgs = { inherit inputs system; };
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules =
        [
          ./nixos/cli.nix
          ./nixos/desktop.nix
          ./nixos/dev.nix
          ./nixos/laptop.nix
          ./nixos/misc.nix
          # ./nixos/optimus.nix
          ./nixos/xserver.nix
          ./overlays
        ];
      specialArgs = { inherit inputs system; };
    };
  };
}
