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
      libEx = import ./lib inputs;
    in
    libEx.recursiveMergeAttrs (
      [
        {
          lib = libEx;
          templates = {
            default = self.outputs.templates.new-host;
            new-host = {
              path = ./templates/new-host;
              description = "Create a new host";
            };
          };
          internal = {
            configs = import ./configs;
            sharedModules.default = import ./modules/shared;
          };
          darwinModules.default = import ./modules/nix-darwin;
          homeModules.default = import ./modules/home-manager;
          nixosModules.default = import ./modules/nixos;
          overlays.default = import ./overlays { inherit (self) inputs outputs; };
        }

        (libEx.eachDefaultSystem (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config = self.outputs.internal.configs.nixpkgs;
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
      ]
      ++
        # NixOS configs
        (libEx.mapDir (hostname: libEx.mkNixOSConfig { inherit hostname; }) ./hosts/nixos)
      ++
        # nix-darwin configs
        (libEx.mapDir (hostname: libEx.mkNixDarwinConfig { inherit hostname; }) ./hosts/nix-darwin)
      ++
        # Home-Manager configs
        (libEx.mapDir (hostname: libEx.mkHomeConfig { inherit hostname; }) ./hosts/home-manager)
    );

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
