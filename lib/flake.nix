{ self, nixpkgs, nix-darwin, home, flake-utils, ... }@inputs:

let
  inherit (flake-utils.lib) eachDefaultSystem mkApp;
in
{
  mkGHActionsYAMLs = names: eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      mkGHActionsYAML = name:
        let
          file = import (../actions/${name}.nix);
          json = builtins.toJSON file;
        in
        pkgs.runCommand name { } ''
          mkdir -p $out
          echo ${pkgs.lib.escapeShellArg json} | ${pkgs.yj}/bin/yj -jy > $out/${name}.yml
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
    , deps ? pkgs: with pkgs; [ coreutils findutils nixpkgs-fmt nixFlakes ]
    }: eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
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
    , system ? "x86_64-linux"
    , nixosSystem ? nixpkgs.lib.nixosSystem
    , extraModules ? [ ]
    }:
    {
      nixosConfigurations.${hostname} = nixosSystem {
        inherit system;
        modules = [ ../hosts/${hostname} ] ++ extraModules;
        specialArgs = {
          inherit system;
          flake = self;
        };
      };

      apps.${system} = {
        "nixosActivations/${hostname}" = mkApp {
          drv = self.outputs.nixosConfigurations.${hostname}.config.system.build.toplevel;
          exePath = "/activate";
        };

        "nixosVMs/${hostname}" = let pkgs = import nixpkgs { inherit system; }; in
          mkApp {
            drv = pkgs.writeShellScriptBin "run-${hostname}-vm" ''
              env QEMU_OPTS="''${QEMU_OPTS:--cpu host -smp 4 -m 4096M -machine type=q35}" \
                ${self.outputs.nixosConfigurations.${hostname}.config.system.build.vm}/bin/run-${hostname}-vm
            '';
            exePath = "/bin/run-${hostname}-vm";
          };
      };

      checks.${system}."nixosChecks/${hostname}" =
        self.outputs.nixosConfigurations.${hostname}.config.system.build.toplevel;
    };

  mkDarwinConfig =
    { hostname
    , system ? "x86_64-darwin"
    , darwinSystem ? nix-darwin.lib.darwinSystem
    , extraModules ? [ ]
    }:
    {
      darwinConfigurations.${hostname} = darwinSystem {
        inherit system;
        modules = [ ../hosts/${hostname} ] ++ extraModules;
        specialArgs = {
          inherit system;
          flake = self;
        };
      };

      apps.${system}."darwinActivations/${hostname}" = mkApp {
        drv = self.outputs.darwinConfigurations.${hostname}.system;
        exePath = "/activate";
      };

      checks.${system}."darwinChecks/${hostname}" =
        self.outputs.darwinConfigurations.${hostname}.system;
    };

  # https://github.com/nix-community/home-manager/issues/1510
  mkHomeConfig =
    { hostname
    , username ? "thiagoko"
    , homePath ? "/home"
    , configPosfix ? "Projects/nix-configs"
    , configuration ? ../home-manager
    , deviceType ? "desktop"
    , system ? "x86_64-linux"
    , homeManagerConfiguration ? home.lib.homeManagerConfiguration
    }:
    {
      homeConfigurations.${hostname} = homeManagerConfiguration rec {
        inherit username configuration system;
        homeDirectory = "${homePath}/${username}";
        stateVersion = "22.05";
        extraSpecialArgs = {
          inherit system;
          flake = self;
          super = {
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

      checks.${system}."homeChecks/${hostname}" =
        self.outputs.homeConfigurations.${hostname}.activationPackage;
    };
}
