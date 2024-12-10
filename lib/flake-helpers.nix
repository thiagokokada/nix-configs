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
      inherit (self.outputs.nixosConfigurations.${hostname}) config pkgs;
      inherit (nixpkgs.legacyPackages.${system}) applyPatches fetchpatch;

      patches = [
        # https://github.com/NixOS/nixpkgs/pull/363922
        (fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/commit/ae6664cc5110afc4aa214c1bd9013899f6324a07.patch";
          hash = "sha256-H7RXLGDwtWtLeXfrMVSd0Mab89JNoqhumKu/dE3lqVc=";
        })
        (fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/commit/43e6aa5bd29e0a330462127b96c694392291bd49.patch";
          hash = "sha256-GirvMkd5T1dKDxaQrWWAOqTtSLvHzd7+GhjzYvedI5c=";
        })
        (fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/commit/d4c1d6c482f920bbd070304ed573631339258f37.patch";
          hash = "sha256-iimCxs7LvJWrFTGWTeFvMzguf0s3ZKRfJfB2hBn0qFQ=";
        })
        (fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/commit/14ab7a484d2c044d344aa2a41072e34f531515e8.patch";
          hash = "sha256-8SQUWkhBkdq7IA7Ln6Z9YMu0LqkiZy9PGHcppEYHwjM=";
        })
        (fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/commit/c27b1c401ae659d20e4ed5bd6a50d31f7872fdce.patch";
          hash = "sha256-eYhDc4LbpGxk7nvpghivfYYXuZ9Goq9Sf63hy75HItE=";
        })
      ];

      nixosSystem =
        args:
        if patches != [ ] then
          let
            nixpkgs' = applyPatches {
              inherit patches;
              name = "nixpkgs-patched";
              src = nixpkgs;
            };
          in
          import (nixpkgs' + "/nixos/lib/eval-config.nix") args
        else
          nixpkgs.lib.nixosSystem args;
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
