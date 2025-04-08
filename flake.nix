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
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # helpers
    flake-compat.url = "github:edolstra/flake-compat";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-alien
    nix-index-database.follows = "nix-alien/nix-index-database";
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # gh
    gh-gfm-preview = {
      url = "github:thiagokokada/gh-gfm-preview";
      inputs.flake-compat.follows = "flake-compat";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
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

      (lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = import ./modules/shared/config/nixpkgs.nix;
            overlays = [ self.overlays.default ];
          };
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
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
          checks.formatting = treefmtEval.config.build.check self;
          formatter = treefmtEval.config.build.wrapper;
          legacyPackages = pkgs;
        }
      ))

      # NixOS configs
      (lib.mkNixOSConfig { hostname = "hachune-nixos"; })
      (lib.mkNixOSConfig { hostname = "sankyuu-nixos"; })
      (lib.mkNixOSConfig { hostname = "zatsune-nixos"; })
      (lib.mkNixOSConfig { hostname = "zachune-nixos"; })

      # nix-darwin configs
      (lib.mkNixDarwinConfig {
        hostname = "Sekai-MacBook-Pro";
        extraModules = [
          { nix-darwin.home.extraModules = [ { home-manager.editor.idea.enable = true; } ]; }
        ];
      })

      # Home-Manager configs
      (lib.mkHomeConfig { hostname = "home-linux"; })
      (lib.mkHomeConfig {
        hostname = "steamdeck";
        username = "deck";
      })
      (lib.mkHomeConfig {
        hostname = "droid";
        username = "droid";
        system = "aarch64-linux";
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
