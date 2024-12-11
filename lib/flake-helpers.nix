{ self, flake-utils, ... }@inputs:

let
  inherit (flake-utils.lib) eachDefaultSystem mkApp;
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
                action-validator
                yj
              ];
              json = builtins.toJSON (import ../actions/${name}.nix);
              passAsFile = [ "json" ];
            }
            ''
              mkdir -p $out
              yj -jy < "$jsonPath" > $out/${name}.yml
              action-validator -v $out/${name}.yml
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
      }
    );

  mkRunCmd =
    {
      name,
      text,
      deps ? pkgs: [ ],
    }:
    eachDefaultSystem (
      system:
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
      }
    );

  mkNixOSConfig =
    {
      hostname,
      system ? "x86_64-linux",
      nixpkgs ? inputs.nixpkgs,
      extraModules ? [ ],
    }:
    let
      inherit (self.outputs.nixosConfigurations.${hostname}) config;
      n = import ../patches { inherit self nixpkgs system; };

      nixosSystem =
        if n.patched then
          (import (n.nixpkgs + "/nixos/lib/eval-config.nix"))
        else
          n.nixpkgs.lib.nixosSystem;
    in
    {
      nixosConfigurations.${hostname} = nixosSystem {
        inherit system;
        modules = [
          (
            { lib, ... }:
            {
              networking.hostName = lib.mkDefault hostname;
            }
          )
          ../hosts/${hostname}
        ] ++ extraModules;
        specialArgs = {
          flake = self;
          libEx = self.outputs.lib;
        };
      };

      apps.${system} = {
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

  mkNixDarwinConfig =
    {
      hostname,
      nix-darwin ? inputs.nix-darwin,
      extraModules ? [ ],
    }:
    let
      inherit (self.outputs.darwinConfigurations.${hostname}) pkgs;
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        modules = [
          (
            { lib, ... }:
            {
              networking.hostName = lib.mkDefault hostname;
            }
          )
          ../hosts/${hostname}
        ] ++ extraModules;
        specialArgs = {
          flake = self;
          libEx = self.outputs.lib;
        };
      };

      apps.${pkgs.system} = {
        "darwinActivations/${hostname}" = mkApp {
          drv = pkgs.writeShellScriptBin "activate" ''
            ${
              pkgs.lib.getExe' nix-darwin.packages.${pkgs.system}.darwin-rebuild "darwin-rebuild"
            } switch --flake '.#${hostname}'
          '';
        };
      };
    };

  # https://github.com/nix-community/home-manager/issues/1510
  mkHomeConfig =
    {
      hostname,
      username ? "thiagoko",
      homePath ? "/home",
      homeDirectory ? "${homePath}/${username}",
      configuration ? ../home-manager,
      deviceType ? "desktop",
      extraModules ? [ ],
      system ? "x86_64-linux",
      nixpkgs ? inputs.nixpkgs,
      home-manager ? inputs.home-manager,
      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      stateVersion ? "24.05",
    }:
    {
      homeConfigurations.${hostname} = home-manager.lib.homeManagerConfiguration {
        pkgs = self.outputs.legacyPackages.${system};
        modules = [
          (
            { ... }:
            {
              home = {
                inherit username homeDirectory stateVersion;
              };
              imports = [ configuration ];
            }
          )
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
