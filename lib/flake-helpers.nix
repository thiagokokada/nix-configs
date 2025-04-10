{
  self,
  nixpkgs,
  nix-darwin,
  home-manager,
  ...
}:

let
  attrsets = import ./attrsets.nix { inherit (nixpkgs) lib; };
  inherit (attrsets) eachDefaultSystem;
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
  mkGHActionsYAMLs =
    names:
    eachDefaultSystem (
      system:
      let
        pkgs = self.outputs.legacyPackages.${system};
        mkGHActionsYAML =
          name:
          pkgs.runCommand name
            {
              buildInputs = with pkgs; [
                actionlint
                yj
              ];
              json = builtins.toJSON (import ../actions/${name}.nix);
              passAsFile = [ "json" ];
            }
            ''
              mkdir -p $out
              yj -jy < "$jsonPath" > $out/${name}.yml
              actionlint -verbose $out/${name}.yml
            '';
        ghActionsYAMLs = map mkGHActionsYAML names;
      in
      {
        apps.githubActions = {
          type = "app";
          program = nixpkgs.lib.getExe (
            pkgs.writeShellScriptBin "generate-gh-actions" ''
              for dir in ${builtins.toString ghActionsYAMLs}; do
                cp -f $dir/*.yml .github/workflows/
              done
              echo Done!
            ''
          );
        };
      }
    );

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
        };

        "nixosVMs/${hostname}" = {
          type = "app";
          program = nixpkgs.lib.getExe config.system.build.vm;
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
              ${
                pkgs.lib.getExe' nix-darwin.packages.${pkgs.system}.darwin-rebuild "darwin-rebuild"
              } switch --flake '.#${hostname}'
            ''
          );
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
      };
    };
}
