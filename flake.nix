{
  description = "My Nix{OS} configuration files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay/e3da699893c4be3b946d3586143b03450f9680ee";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = { self, nixpkgs, home, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules =
        [
          ./nixos/cli.nix
          ./nixos/desktop.nix
          ./nixos/dev.nix
          ./nixos/game.nix
          ./nixos/home.nix
          ./nixos/misc.nix
          ./nixos/pc.nix
          ./nixos/theme.nix
          ./nixos/xserver.nix
          ./modules/my.nix
          ./overlays
          home.nixosModules.home-manager
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
          ./nixos/home.nix
          ./nixos/misc.nix
          # ./nixos/optimus.nix
          ./nixos/theme.nix
          ./nixos/xserver.nix
          ./modules/my.nix
          ./overlays
          home.nixosModules.home-manager
        ];
      specialArgs = { inherit inputs system; };
    };

    # https://github.com/nix-community/home-manager/issues/1510
    homeConfigurations.home = home.lib.homeManagerConfiguration rec {
      configuration = import ./home-manager/home.nix { inherit inputs system; };
      system = "x86_64-linux";
      homeDirectory = "/home/thiagoko";
      username = "thiagoko";
    };

    home = self.homeConfigurations.home.activationPackage;
  };
}
