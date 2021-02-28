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
      url = "github:nix-community/emacs-overlay/afa5bd8ca44e25f2ef16ad73f7305cecab35f6a4";
      inputs.nixpkgs.follows = "unstable";
    };
    nubank.url = "github:nubank/nixpkgs/master";
  };

  outputs = { self, nixpkgs, home, ... }@inputs: {
    nixosConfigurations.miku-nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ ./hosts/miku-nixos ];
      specialArgs = { inherit inputs system; };
    };

    nixosConfigurations.mikudayo-nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ ./hosts/mikudayo-nixos ];
      specialArgs = { inherit inputs system; };
    };

    nixosConfigurations.mikudayo-nubank = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ ./hosts/mikudayo-nubank ];
      specialArgs = { inherit inputs system; };
    };

    nixosConfigurations.mirai-vps = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ ./hosts/mirai-vps ];
      specialArgs = { inherit inputs system; };
    };

    # https://github.com/nix-community/home-manager/issues/1510
    homeConfigurations.home-linux = home.lib.homeManagerConfiguration rec {
      configuration = ./home-manager/home.nix;
      system = "x86_64-linux";
      homeDirectory = "/home/thiagoko";
      username = "thiagoko";
      extraSpecialArgs = {
        inherit inputs system;
        super = { device.type = "desktop"; };
      };
    };
  };
}
