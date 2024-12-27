{
  description = "My Nix{OS} configuration files";

  inputs = {
    # main
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # helpers
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";

    # nix-alien
    nix-index-database.follows = "nix-alien/nix-index-database";
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # emacs
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };

    # IntelliJ
    intellimacs = {
      url = "github:MarcoIeni/intellimacs";
      flake = false;
    };

    # custom packages
    arandr = {
      url = "gitlab:thiagokokada/arandr";
      flake = false;
    };

    # hyprland
    hyprland-go = {
      url = "github:thiagokokada/hyprland-go";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # yazi
    yazi-flavors = {
      url = "github:yazi-rs/flavors";
      flake = false;
    };

    # wezterm
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
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
    zim-utility = {
      url = "github:zimfw/utility";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    let
      lib = import ./lib inputs;
    in
    lib.recursiveMergeAttrs [
      {
        inherit lib;
        templates = {
          default = self.outputs.templates.new-host;
          new-host = {
            path = ./templates/new-host;
            description = "Create a new host";
          };
        };
        overlays.default = import ./overlays { flake = self; };
        darwinModules.default = import ./modules/nix-darwin;
        homeModules.default = import ./modules/home-manager;
        nixosModules.default = import ./modules/nixos;
      }

      (flake-utils.lib.eachDefaultSystem (
        system:
        let
          inherit (import ./patches { inherit self nixpkgs system; }) pkgs;
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              fd
              neovim-standalone
              nil
              nixfmt-rfc-style
              ripgrep
              statix
            ];
          };
          checks = import ./checks.nix { inherit pkgs; };
          formatter = pkgs.nixfmt-rfc-style;
          legacyPackages = pkgs;
        }
      ))

      # NixOS configs
      (lib.mkNixOSConfig { hostname = "hachune-nixos"; })
      (lib.mkNixOSConfig { hostname = "miku-nixos"; })
      (lib.mkNixOSConfig { hostname = "mirai-nixos"; })
      (lib.mkNixOSConfig { hostname = "sankyuu-nixos"; })
      (lib.mkNixOSConfig {
        hostname = "zatsune-nixos";
        system = "aarch64-linux";
      })
      (lib.mkNixOSConfig { hostname = "zachune-nixos"; })

      # nix-darwin configs
      (lib.mkNixDarwinConfig {
        hostname = "Sekai-MacBook-Pro";
        extraModules = [
          { nix-darwin.home.extraModules = [ { home-manager.editor.jetbrains.enable = true; } ]; }
        ];
      })

      # Home-Manager configs
      (lib.mkHomeConfig {
        hostname = "home-linux-desktop";
        extraModules = [
          {
            home-manager = {
              desktop.enable = true;
              dev.enable = true;
            };
          }
        ];
      })
      (lib.mkHomeConfig {
        hostname = "home-linux";
        extraModules = [ { home-manager.dev.enable = true; } ];
      })
      (lib.mkHomeConfig {
        hostname = "home-linux-wsl";
        extraModules = [
          {
            home-manager = {
              dev.enable = true;
              # https://github.com/nix-community/home-manager/issues/5025
              meta.sdSwitch.enable = false;
            };
          }
        ];
      })
      (lib.mkHomeConfig {
        hostname = "steamdeck";
        username = "deck";
      })
      (lib.mkHomeConfig {
        hostname = "penguin";
        system = "aarch64-linux";
        extraModules = [ { home-manager.crostini.enable = true; } ];
      })
      (lib.mkHomeConfig {
        hostname = "home-macos";
        system = "aarch64-darwin";
        homePath = "/Users";
      })

      # Commands
      (lib.mkRunCmd {
        name = "linter";
        deps = pkgs: with pkgs; [ statix ];
        text = "statix fix -i hardware-configuration.nix";
      })

      # GitHub Actions
      (lib.mkGHActionsYAMLs [
        "build-and-cache"
        "update-flakes"
        "update-flakes-darwin"
        "validate-flakes"
      ])

    ]; # END recursiveMergeAttrs

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://thiagokokada-nix-configs.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "thiagokokada-nix-configs.cachix.org-1:MwFfYIvEHsVOvUPSEpvJ3mA69z/NnY6LQqIQJFvNwOc="
    ];
  };
}
