{
  self,
  nixpkgs,
  nix-darwin,
  home-manager,
  ...
}:

let
  setHostname =
    hostname:
    (
      { lib, ... }:
      {
        networking.hostName = lib.mkDefault hostname;
      }
    );
in
{
  mkNixOSConfig =
    {
      hostname,
      configuration ? ../hosts/nixos/${hostname},
    }:
    let
      inherit (self.outputs.nixosConfigurations.${hostname}) config pkgs;
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        modules = [
          (setHostname hostname)
          self.outputs.nixosModules.default
          configuration
        ];
        specialArgs = {
          flake = self;
          libEx = self.outputs.lib;
        };
      };

      apps.${pkgs.system} = {
        "nixosActivations/${hostname}" = {
          type = "app";
          program = "${config.system.build.toplevel}/activate";
          meta.description = "NixOS activation script for ${hostname}";
        };

        "nixosVMs/${hostname}" = {
          type = "app";
          program = nixpkgs.lib.getExe config.system.build.vm;
          meta.description = "NixOS VM test for ${hostname}";
        };
      };
    };

  mkNixDarwinConfig =
    {
      hostname,
      configuration ? ../hosts/nix-darwin/${hostname},
    }:
    let
      inherit (self.outputs.darwinConfigurations.${hostname}) pkgs;
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        modules = [
          (setHostname hostname)
          self.outputs.darwinModules.default
          configuration
        ];
        specialArgs = {
          flake = self;
          libEx = self.outputs.lib;
        };
      };

      apps.${pkgs.system} = {
        "darwinActivations/${hostname}" = {
          type = "app";
          program = nixpkgs.lib.getExe (
            pkgs.writeShellScriptBin "activate" ''
              sudo ${
                pkgs.lib.getExe' nix-darwin.packages.${pkgs.system}.darwin-rebuild "darwin-rebuild"
              } switch --flake '.#${hostname}'
            ''
          );
          meta.description = "nix-darwin activation script for ${hostname}";
        };
      };
    };

  # https://github.com/nix-community/home-manager/issues/1510
  mkHomeConfig =
    {
      hostname,
      username ? "thiagoko",
      configuration ? ../hosts/home-manager/${hostname},
      system ? import ../hosts/home-manager/${hostname}/system.nix,
    }:
    {
      homeConfigurations.${hostname} = home-manager.lib.homeManagerConfiguration {
        pkgs = self.outputs.legacyPackages.${system};
        modules = [
          self.outputs.homeModules.default
          configuration
        ];
        extraSpecialArgs = {
          flake = self;
          libEx = self.outputs.lib;
          osConfig = { };
        };
      };

      apps.${system}."homeActivations/${hostname}" = {
        type = "app";
        program = "${self.outputs.homeConfigurations.${hostname}.activationPackage}/activate";
        meta.description = "Home activation script for ${hostname}";
      };
    };
}
