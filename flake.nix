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
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # helpers
    flake-compat.url = "github:edolstra/flake-compat";
    flake-utils.url = "github:numtide/flake-utils";

    # nix-alien
    nix-index-database.follows = "nix-alien/nix-index-database";
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
    };

    # twenty-twenty-twenty
    twenty-twenty-twenty = {
      url = "github:thiagokokada/twenty-twenty-twenty";
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

    # nnn plugins
    nnn-plugins = {
      url = "github:jarun/nnn";
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
    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      inherit (import ./lib/attrsets.nix { inherit (nixpkgs) lib; }) recursiveMergeAttrs;
      inherit (import ./lib/flake-helpers.nix inputs) mkGHActionsYAMLs mkRunCmd mkNixOSConfig mkHomeConfig;
      inherit (import ./lib/impure.nix { }) getEnvOrDefault;
    in
    recursiveMergeAttrs [
      # Templates
      {
        templates = {
          default = self.outputs.templates.new-host;
          new-host = {
            path = ./templates/new-host;
            description = "Create a new host";
          };
        };
        overlays.default = import ./overlays { flake = self; };
      }

      # NixOS configs
      (mkNixOSConfig { hostname = "hachune-nixos"; })
      (mkNixOSConfig { hostname = "miku-nixos"; })
      (mkNixOSConfig { hostname = "mirai-nixos"; })
      (mkNixOSConfig { hostname = "sankyuu-nixos"; })
      (mkNixOSConfig { hostname = "zatsune-nixos"; })
      (mkNixOSConfig { hostname = "zachune-nixos"; })

      # Home-Manager generic configs
      (mkHomeConfig {
        hostname = "home-linux-desktop";
        extraModules = [{
          home-manager = {
            desktop.enable = true;
            dev.enable = true;
          };
        }];
      })
      (mkHomeConfig {
        hostname = "home-linux";
        extraModules = [{ home-manager.dev.enable = true; }];
      })
      (mkHomeConfig {
        hostname = "home-linux-minimal";
        username = getEnvOrDefault "USER" "thiagoko";
        homePath = (getEnvOrDefault "TMPDIR" "/tmp") + "/home";
        configuration = ./home-manager/minimal.nix;
      })
      (mkHomeConfig {
        hostname = "home-macos";
        system = "x86_64-darwin";
        homePath = "/Users";
      })
      # Home-Manager specific configs
      (mkHomeConfig {
        hostname = "steamdeck";
        username = "deck";
      })
      (mkHomeConfig {
        hostname = "penguin";
        system = "aarch64-linux";
        extraModules = [
          ({ pkgs, libEx, ... }: {
            home-manager.crostini.enable = true;

            home.packages = with pkgs; [
              deluge
              (libEx.nixGLWrapper {
                pkg = retroarch.override {
                  cores = with libretro; [
                    beetle-supafaust
                    gambatte
                    genesis-plus-gx
                    melonds
                    mgba
                    nestopia
                    pcsx-rearmed
                    stella
                  ];
                  # OpenGL window is too small
                  settings = { "video_driver" = "sdl2"; };
                };
              })
            ];
          })
        ];
      })
      (mkHomeConfig {
        hostname = "toasty";
        username = "thiago.okada";
        system = "aarch64-darwin";
        homePath = "/Users";
        extraModules = [{
          home-manager = {
            editor.jetbrains.enable = true;
            dev = {
              clojure.enable = false;
              go.enable = false;
              node.enable = false;
            };
          };
        }];
      })

      # Commands
      (mkRunCmd {
        name = "linter";
        deps = pkgs: with pkgs; [ statix ];
        text = "statix fix -i hardware-configuration.nix";
      })

      # GitHub Actions
      (mkGHActionsYAMLs [
        "build-and-cache"
        "update-flakes"
        "update-flakes-darwin"
        "validate-flakes"
      ])

      (flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };
        in
        {
          devShells.default = import ./dev-shell.nix {
            inherit pkgs;
            homeManagerConfiguration = self.outputs.homeConfigurations.home-linux-minimal;
          };
          checks = import ./checks.nix { inherit pkgs; };
          formatter = pkgs.nixpkgs-fmt;
          legacyPackages = pkgs;
        }))
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
