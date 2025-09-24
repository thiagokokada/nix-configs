{
  self,
  nixpkgs,
  nix-darwin,
  home-manager,
  ...
}:

let
  setDefaultHostName =
    hostName:
    (
      { lib, ... }:
      {
        networking.hostName = lib.mkDefault hostName;
      }
    );
  specialArgs = {
    flake = self;
    libEx = self.outputs.lib;
  };
in
{
  mkNixOSConfig =
    {
      hostName,
      configuration,
    }:
    let
      inherit (self.outputs.nixosConfigurations.${hostName}) config pkgs;
    in
    {
      nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          (setDefaultHostName hostName)
          self.outputs.nixosModules.default
          configuration
        ];
      };

      apps.${pkgs.system} = {
        "nixosActivations/${hostName}" = {
          type = "app";
          program = "${config.system.build.toplevel}/activate";
          meta.description = "NixOS activation script for ${hostName}";
        };

        "nixosVMs/${hostName}" = {
          type = "app";
          program = nixpkgs.lib.getExe config.system.build.vm;
          meta.description = "NixOS VM test for ${hostName}";
        };
      };
    };

  mkNixDarwinConfig =
    {
      hostName,
      configuration,
    }:
    let
      inherit (self.outputs.darwinConfigurations.${hostName}) pkgs config;
      inherit (config.system.build) darwin-rebuild;
    in
    {
      darwinConfigurations.${hostName} = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [
          (setDefaultHostName hostName)
          self.outputs.darwinModules.default
          configuration
        ];
      };

      apps.${pkgs.system} = {
        "darwinActivations/${hostName}" = {
          type = "app";
          program = nixpkgs.lib.getExe (
            pkgs.writeShellScriptBin "activate" ''
              sudo ${pkgs.lib.getExe darwin-rebuild} switch --flake '.#${hostName}'
            ''
          );
          meta.description = "nix-darwin activation script for ${hostName}";
        };
      };
    };

  mkHomeConfig =
    {
      hostName,
      configuration,
      system,
    }:
    {
      homeConfigurations.${hostName} = home-manager.lib.homeManagerConfiguration {
        pkgs = self.outputs.legacyPackages.${system};
        modules = [
          self.outputs.homeModules.default
          configuration
        ];
        extraSpecialArgs = specialArgs;
      };

      apps.${system}."homeActivations/${hostName}" = {
        type = "app";
        program = "${self.outputs.homeConfigurations.${hostName}.activationPackage}/activate";
        meta.description = "Home activation script for ${hostName}";
      };
    };
}
