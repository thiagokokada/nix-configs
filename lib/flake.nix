{ self, nixpkgs, home, flake-utils, ... }:

let
  inherit (flake-utils.lib) eachDefaultSystem mkApp;
in
{
  mkGHActionsYAMLs = names: eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      mkGHActionsYAML = name:
        let
          file = import (../actions/${name}.nix);
          json = builtins.toJSON file;
        in
        pkgs.runCommand name { } ''
          mkdir -p $out
          echo ${nixpkgs.lib.escapeShellArg json} | ${pkgs.yj}/bin/yj -jy > $out/${name}.yml
        '';
      ghActionsYAMLs = (map mkGHActionsYAML names);
    in
    {
      apps.githubActions = mkApp {
        drv = pkgs.writeShellScriptBin "generate-gh-actions" ''
          for dir in ${builtins.toString ghActionsYAMLs}; do
            cp -f $dir/*.yml .github/workflows/
          done
          echo Done!
        '';
        exePath = "/bin/generate-gh-actions";
      };
    });

  mkRunCmd =
    { name
    , text
    , deps ? pkgs: with pkgs; [ coreutils findutils nixpkgs-fmt ]
    }: eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      apps.${name} = mkApp {
        drv = pkgs.writeShellApplication {
          inherit name text;
          runtimeInputs = (deps pkgs);
        };
        exePath = "/bin/${name}";
      };
    });

  mkNixOSConfig =
    { hostname
    , system ? null # get from hardware-configuration.nix by default
    , nixosSystem ? nixpkgs.lib.nixosSystem
    , extraModules ? [ ]
    }:
    {
      nixosConfigurations.${hostname} = nixosSystem {
        inherit system;
        modules = [ ../hosts/${hostname} ] ++ extraModules;
        lib = nixpkgs.lib.extend (final: prev:
          (import ../lib { lib = final; })
        );
        specialArgs.flake = self;
      };

      apps.${system} = {
        "nixosActivations/${hostname}" = mkApp {
          drv = self.outputs.nixosConfigurations.${hostname}.config.system.build.toplevel;
          exePath = "/activate";
        };

        "nixosVMs/${hostname}" = let pkgs = nixpkgs.legacyPackages.${system}; in
          mkApp {
            drv = pkgs.writeShellScriptBin "run-${hostname}-vm" ''
              env QEMU_OPTS="''${QEMU_OPTS:--cpu max -smp 4 -m 4096M -machine type=q35}" \
                ${self.outputs.nixosConfigurations.${hostname}.config.system.build.vm}/bin/run-${hostname}-vm
            '';
            exePath = "/bin/run-${hostname}-vm";
          };
      };
    };

  # https://github.com/nix-community/home-manager/issues/1510
  mkHomeConfig =
    { hostname
    , username ? "thiagoko"
    , homePath ? "/home"
    , configPosfix ? "Projects/nix-configs"
    , configuration ? ../home-manager
    , deviceType ? "desktop"
    , extraModules ? [ ]
    , system ? "x86_64-linux"
    , homeManagerConfiguration ? home.lib.homeManagerConfiguration
    }:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      homeDirectory = "${homePath}/${username}";
    in
    {
      homeConfigurations.${hostname} = homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ({ ... }: {
            home = { inherit username homeDirectory; };
            imports = [ configuration ];
          })
        ] ++ extraModules;
        lib = nixpkgs.lib.extend (final: prev:
          (import ../lib { lib = final; })
        );
        extraSpecialArgs = {
          flake = self;
          osConfig = {
            device.type = deviceType;
            meta.username = username;
            meta.configPath = "${homeDirectory}/${configPosfix}";
          };
        };
      };

      apps.${system}."homeActivations/${hostname}" = mkApp {
        drv = self.outputs.homeConfigurations.${hostname}.activationPackage;
        exePath = "/activate";
      };
    };
}
