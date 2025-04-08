{ self, nixpkgs, ... }@inputs:

let
  attrsets = import ./attrsets.nix { inherit (nixpkgs) lib; };
  inherit (attrsets) eachDefaultSystem;
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
      nixpkgs ? inputs.nixpkgs,
      extraModules ? [ ],
    }:
    let
      inherit (self.outputs.nixosConfigurations.${hostname}) config pkgs;
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        modules = [
          (
            { lib, ... }:
            {
              networking.hostName = lib.mkDefault hostname;
            }
          )
          ../hosts/nixos/${hostname}
        ] ++ extraModules;
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
      nix-darwin ? inputs.nix-darwin,
      extraModules ? [ ],
    }:
    let
      # TODO: use self.outputs.legacyPackages instead to allow for patching
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
          ../hosts/nix-darwin/${hostname}
        ] ++ extraModules;
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
      homePath ? "/home",
      homeDirectory ? "${homePath}/${username}",
      configuration ? self.outputs.homeModules.default,
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
            meta.username = username;
          };
        };
      };

      apps.${system}."homeActivations/${hostname}" = {
        type = "app";
        program = "${self.outputs.homeConfigurations.${hostname}.activationPackage}/activate";
      };
    };
}
