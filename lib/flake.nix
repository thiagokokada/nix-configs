{ self, nixpkgs, nix-darwin, home, ... }@inputs:

{
  buildGHActionsYAMLFor = pkgs: name:
    let
      file = import (../actions/${name}.nix);
      json = builtins.toJSON file;
    in
    {
      ${name} = pkgs.writeShellScriptBin name ''
        echo ${pkgs.lib.escapeShellArg json} | ${pkgs.yj}/bin/yj -jy;
      '';
    };

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
    };

  # https://github.com/nix-community/home-manager/issues/1510
  mkHomeConfig =
    { name
    , username ? "thiagoko"
    , homePath ? "/home"
    , configPosfix ? "Projects/nix-configs"
    , configuration ? ../home-manager
    , deviceType ? "desktop"
    , system ? "x86_64-linux"
    , homeManagerConfiguration ? home.lib.homeManagerConfiguration
    }:
    {
      homeConfigurations.${name} = homeManagerConfiguration rec {
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
            fonts.fontconfig = {
              antialias = true;
              hinting = {
                enable = true;
                style = "hintslight";
              };
              subpixel.lcdfilter = "rgb";
            };
          };
        };
      };
    };
}
