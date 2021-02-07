{
  description = "My Nix{OS} configuration files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home.url = "github:nix-community/home-manager/release-20.09";
  };

  outputs = { self, nixpkgs, unstable, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules =
        [
          ./nixos/desktop.nix
          ./nixos/misc.nix
          ./nixos/game.nix
          ./overlays
        ];
      specialArgs = { inherit inputs system; };
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules =
        [
          ./nixos/desktop.nix
          ./nixos/laptop.nix
          ./nixos/misc.nix
          ./overlays
        ];
      specialArgs = { inherit inputs system; };
    };
  };
}
