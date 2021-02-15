{
  description = "My Nix{OS} configuration files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home = {
      url =
        "github:thiagokokada/home-manager/release-20.09_backports-from-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay/master";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = { self, nixpkgs, home, ... }@inputs: {
    nixosConfigurations.miku-nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./nixos/cli.nix
        ./nixos/desktop.nix
        ./nixos/dev.nix
        ./nixos/fonts.nix
        ./nixos/game.nix
        ./nixos/home.nix
        ./nixos/locale.nix
        ./nixos/misc.nix
        ./nixos/pc.nix
        ./nixos/security.nix
        ./nixos/system.nix
        ./nixos/xserver.nix
        ./hosts/miku-nixos
        ./modules/device.nix
        ./modules/my.nix
        ./overlays
        home.nixosModules.home-manager
        ({ pkgs, ... }: {
          device.type = "desktop";
        })
      ];
      specialArgs = { inherit inputs system; };
    };

    nixosConfigurations.mikudayo-nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./nixos/cli.nix
        ./nixos/desktop.nix
        ./nixos/dev.nix
        ./nixos/fonts.nix
        ./nixos/home.nix
        ./nixos/laptop.nix
        ./nixos/locale.nix
        ./nixos/misc.nix
        # ./nixos/optimus.nix
        ./nixos/system.nix
        ./nixos/xserver.nix
        ./hosts/mikudayo-nixos
        ./modules/device.nix
        ./modules/my.nix
        ./overlays
        home.nixosModules.home-manager
        ({ pkgs, ... }: {
          device.type = "notebook";
          device.mountPoints = [ "/" ];
        })
      ];
      specialArgs = { inherit inputs system; };
    };

    # https://github.com/nix-community/home-manager/issues/1510
    homeConfigurations.home = home.lib.homeManagerConfiguration rec {
      configuration = ./home-manager/home.nix;
      system = "x86_64-linux";
      homeDirectory = "/home/thiagoko";
      username = "thiagoko";
      extraSpecialArgs = {
        inherit inputs system;
        super = { device.type = "desktop"; };
      };
    };

    home = self.homeConfigurations.home.activationPackage;
  };
}
