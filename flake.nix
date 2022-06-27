{
  description = "My Nix{OS} configuration files";

  inputs = {
    # main
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    # TODO: remove once merged
    add-hintstyle-config.url = "github:thiagokokada/nixpkgs/add-hintstyle-config";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";
    home = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "unstable";
    };

    # helpers
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";

    # nix-alien
    poetry2nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };

    # overlays
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    # nnn plugins
    nnn-plugins = {
      url = "github:jarun/nnn/v4.5";
      flake = false;
    };

    # ZSH plugins
    zim-completion = {
      url = "github:zimfw/completion";
      flake = false;
    };
    zim-environment = {
      url = "github:zimfw/environment";
      flake = false;
    };
    zim-input = {
      url = "github:zimfw/input";
      flake = false;
    };
    zim-git = {
      url = "github:zimfw/git";
      flake = false;
    };
    zim-ssh = {
      url = "github:zimfw/ssh";
      flake = false;
    };
    zim-utility = {
      url = "github:zimfw/utility";
      flake = false;
    };
    pure = {
      url = "github:sindresorhus/pure";
      flake = false;
    };
    zsh-autopair = {
      url = "github:hlissner/zsh-autopair";
      flake = false;
    };
    zsh-completions = {
      url = "github:zsh-users/zsh-completions";
      flake = false;
    };
    zsh-history-substring-search = {
      url = "github:zsh-users/zsh-history-substring-search";
      flake = false;
    };
    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting";
      flake = false;
    };
    zsh-system-clipboard = {
      url = "github:kutsan/zsh-system-clipboard";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, unstable, nix-darwin, home, home-unstable, flake-utils, ... }:
    let
      inherit (import ./lib/attrsets.nix { inherit (nixpkgs) lib; }) recursiveMergeAttrs;
    in
    {
      templates = rec {
        default = new-host;
        new-host = {
          path = ./templates/new-host;
          description = "Create a new host";
        };
      };

      nixosConfigurations =
        let
          mkNixOSConfig =
            { hostname
            , system ? "x86_64-linux"
            , nixosSystem ? nixpkgs.lib.nixosSystem
            , extraModules ? [ ]
            }:
            {
              ${hostname} = nixosSystem {
                inherit system;
                modules = [ ./hosts/${hostname} ] ++ extraModules;
                specialArgs = { inherit self system; };
              };
            };
        in
        recursiveMergeAttrs [
          (mkNixOSConfig { hostname = "miku-nixos"; })
          (mkNixOSConfig { hostname = "mikudayo-re-nixos"; })
          (mkNixOSConfig { hostname = "miku-vm"; })
          (mkNixOSConfig { hostname = "mirai-vps"; })
        ];

      darwinConfigurations =
        let
          mkDarwinConfig =
            { hostname
            , system ? "x86_64-darwin"
            , darwinSystem ? nix-darwin.lib.darwinSystem
            , extraModules ? [ ]
            }:
            {
              ${hostname} = darwinSystem {
                inherit system;
                modules = [ ./hosts/${hostname} ] ++ extraModules;
                specialArgs = { inherit self system; };
              };
            };
        in
        recursiveMergeAttrs [
          (mkDarwinConfig { hostname = "miku-macos-vm"; })
        ];

      # https://github.com/nix-community/home-manager/issues/1510
      homeConfigurations =
        let
          mkHomeConfig =
            { name
            , username ? "thiagoko"
            , homePath ? "/home"
            , configPosfix ? "Projects/nix-configs"
            , configuration ? ./home-manager
            , deviceType ? "desktop"
            , system ? "x86_64-linux"
            , homeManagerConfiguration ? home.lib.homeManagerConfiguration
            }:
            {
              ${name} = homeManagerConfiguration rec {
                inherit username configuration system;
                homeDirectory = "${homePath}/${username}";
                stateVersion = "22.05";
                extraSpecialArgs = {
                  inherit self system;
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
        in
        recursiveMergeAttrs [
          (mkHomeConfig { name = "home-linux"; })
          (mkHomeConfig {
            name = "home-macos";
            configuration = ./home-manager/macos.nix;
            system = "x86_64-darwin";
            homePath = "/Users";
          })
        ];
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        buildGHActionsYAML = name:
          let
            file = import (./actions/${name}.nix);
            json = builtins.toJSON file;
          in
          {
            ${name} = pkgs.writeShellScriptBin name ''
              echo ${pkgs.lib.escapeShellArg json} | ${pkgs.yj}/bin/yj -jy;
            '';
          };
      in
      {
        githubActions = recursiveMergeAttrs [
          (buildGHActionsYAML "build-and-cache")
          (buildGHActionsYAML "update-flakes")
          (buildGHActionsYAML "update-flakes-darwin")
        ];

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            coreutils
            findutils
            gnumake
            nixpkgs-fmt
            nixFlakes
          ];
        };
      }
    );
}
