{
  self,
  nixpkgs,
  nix-darwin,
  home-manager,
  system-manager,
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
      inherit (config.system.build) nixos-rebuild;
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

      apps.${pkgs.stdenv.hostPlatform.system} = {
        "nixosActivations/${hostName}" = {
          type = "app";
          program = nixpkgs.lib.getExe (
            pkgs.writeShellScriptBin "activate" ''
              sudo ${pkgs.lib.getExe nixos-rebuild} switch --flake '${self}#${hostName}'
            ''
          );
          meta.description = "NixOS activation script for ${hostName}";
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

      apps.${pkgs.stdenv.hostPlatform.system} = {
        "darwinActivations/${hostName}" = {
          type = "app";
          program = nixpkgs.lib.getExe (
            pkgs.writeShellScriptBin "activate" ''
              sudo ${pkgs.lib.getExe darwin-rebuild} switch --flake '${self}#${hostName}'
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

  mkSystemManagerConfig =
    {
      hostName,
      configuration,
      system,
    }:
    {
      systemConfigs.${hostName} = system-manager.lib.makeSystemConfig {
        overlays = [ self.outputs.overlays.default ];
        modules = [
          home-manager.nixosModules.home-manager
          self.outputs.systemModules.default
          {
            nixpkgs.hostPlatform = system;
          }
          configuration
        ];
        inherit specialArgs;
      };

      apps.${system}."systemActivations/${hostName}" =
        let
          pkgs = self.outputs.legacyPackages.${system};
          system-manager-bin = system-manager.packages.${system}.default;
        in
        {
          type = "app";
          program = nixpkgs.lib.getExe (
            pkgs.writeShellScriptBin "activate-system-manager" ''
              ${nixpkgs.lib.getExe' system-manager-bin "system-manager"} switch --sudo --flake '${self}#${hostName}'
            ''
          );
          meta.description = "system-manager activation script for ${hostName}";
        };
    };
}
