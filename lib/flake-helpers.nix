{ self, nixpkgs, flake-utils, ... }@inputs:

let
  inherit (flake-utils.lib) eachDefaultSystem mkApp;
in
{
  mkGHActionsYAMLs = names: eachDefaultSystem (system:
    let
      inherit (nixpkgs) lib;
      pkgs = self.outputs.legacyPackages.${system};
      mkGHActionsYAML = name:
        let
          file = import (../actions/${name}.nix);
          json = builtins.toJSON file;
        in
        pkgs.runCommand name { } ''
          mkdir -p $out
          echo ${lib.escapeShellArg json} | ${lib.getExe pkgs.yj} -jy > $out/${name}.yml
          ${lib.getExe pkgs.action-validator} -v $out/${name}.yml
        '';
      ghActionsYAMLs = map mkGHActionsYAML names;
    in
    {
      apps.githubActions = mkApp {
        drv = pkgs.writeShellScriptBin "generate-gh-actions" ''
          for dir in ${builtins.toString ghActionsYAMLs}; do
            cp -f $dir/*.yml .github/workflows/
          done
          echo Done!
        '';
      };
    });

  mkRunCmd =
    { name
    , text
    , deps ? pkgs: [ ]
    }: eachDefaultSystem (system:
    let
      pkgs = self.outputs.legacyPackages.${system};
    in
    {
      apps.${name} = mkApp {
        drv = pkgs.writeShellApplication {
          inherit name text;
          runtimeInputs = deps pkgs;
        };
      };
    });

  mkNixOSConfig =
    { hostname
    , system ? null # get from hardware-configuration.nix by default
    , nixpkgs ? inputs.nixpkgs
    , extraModules ? [ ]
    }:
    let
      inherit (self.outputs.nixosConfigurations.${hostname}) config pkgs;
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ lib, ... }: { networking.hostName = lib.mkDefault hostname; })
          ../hosts/${hostname}
        ] ++ extraModules;
        specialArgs = {
          flake = self;
          libEx = self.outputs.lib;
        };
      };

      apps.${pkgs.system} = {
        "nixosActivations/${hostname}" = mkApp {
          drv = config.system.build.toplevel;
          exePath = "/activate";
        };

        "nixosVMs/${hostname}" = mkApp {
          drv = config.system.build.vm;
          exePath = "/bin/run-${hostname}-vm";
        };
      };
    };

  # https://github.com/nix-community/home-manager/issues/1510
  mkHomeConfig =
    { hostname
    , username ? "thiagoko"
    , homePath ? "/home"
    , homeDirectory ? "${homePath}/${username}"
    , configuration ? ../home-manager
    , deviceType ? "desktop"
    , extraModules ? [ ]
    , system ? "x86_64-linux"
    , nixpkgs ? inputs.nixpkgs
    , home-manager ? inputs.home-manager
    }:
    {
      homeConfigurations.${hostname} = home-manager.lib.homeManagerConfiguration {
        pkgs = self.outputs.legacyPackages.${system};
        modules = [
          ({ ... }: {
            home = { inherit username homeDirectory; };
            imports = [ configuration ];
          })
        ] ++ extraModules;
        extraSpecialArgs = {
          flake = self;
          libEx = self.outputs.lib;
          osConfig = {
            device.type = deviceType;
            mainUser.username = username;
          };
        };
      };

      apps.${system}."homeActivations/${hostname}" = mkApp {
        drv = self.outputs.homeConfigurations.${hostname}.activationPackage;
        exePath = "/activate";
      };
    };
}
