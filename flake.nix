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
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # helpers
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";

    # nix-alien
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nix-index-database.follows = "nix-index-database";
    };

    # emacs
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
    zsh-history-substring-search = {
      url = "github:zsh-users/zsh-history-substring-search";
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
      inherit (import ./lib/flake.nix inputs) mkGHActionsYAMLs mkRunCmd mkNixOSConfig mkHomeConfig;
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
      }

      # NixOS configs
      (mkNixOSConfig { hostname = "hachune-nixos"; })
      (mkNixOSConfig { hostname = "miku-nixos"; })
      (mkNixOSConfig { hostname = "mirai-vps"; })
      (mkNixOSConfig { hostname = "sankyuu-nixos"; })
      (mkNixOSConfig { hostname = "zatsune-nixos"; })
      (mkNixOSConfig { hostname = "zachune-nixos"; })

      # Home-Manager configs
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
        hostname = "steamdeck";
        username = "deck";
        configuration = ./home-manager/steamdeck.nix;
      })
      (mkHomeConfig {
        hostname = "home-macos";
        system = "x86_64-darwin";
        homePath = "/Users";
      })

      # Commands
      (mkRunCmd {
        name = "formatCheck";
        deps = pkgs: with pkgs; [ nixpkgs-fmt ];
        text = "nixpkgs-fmt . --check";
      })
      (mkRunCmd {
        name = "format";
        deps = pkgs: with pkgs; [ nixpkgs-fmt ];
        text = "nixpkgs-fmt .";
      })
      (mkRunCmd {
        name = "linterCheck";
        deps = pkgs: with pkgs; [ statix ];
        text = "statix check -i hardware-configuration.nix";
      })
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
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          devShells.default =
            let
              # Needs to run with `--impure` flag because `builtins.getEnv`
              getEnvOrDefault = env: default:
                let envValue = builtins.getEnv env; in
                if envValue != "" then envValue else default;
              tmpdir = getEnvOrDefault "TMPDIR" "/tmp";
              username = getEnvOrDefault "USER" "nobody";
              homePath = "${tmpdir}/home";
              homeManager = (mkHomeConfig {
                inherit homePath username system;
                configuration = ./home-manager/minimal.nix;
                hostname = "devShell";
              }).homeConfigurations.devShell;
              inherit (homeManager.config.home) homeDirectory packages profileDirectory;
            in
            homeManager.pkgs.mkShell {
              inherit packages;
              shellHook = ''
                export HOME=${homeDirectory}
                mkdir -p "$HOME"

                trap "rm -rf ${homePath}" EXIT

                ${homeManager.activationPackage}/activate

                if [[ -L ${profileDirectory}/etc/profile.d/hm-session-vars.sh ]]; then
                  . ${profileDirectory}/etc/profile.d/hm-session-vars.sh
                  zsh -l && exit 0
                else
                  >&2 echo "[ERROR] Could not source Home Manager!"
                  >&2 echo "[ERROR] Did you pass '--impure' flag to 'nix develop'?"
                fi
              '';
            };
        }))

      {
        # Allows the user to use our cache when using `nix run <thisFlake>`.
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
    ]; # END recursiveMergeAttrs
}
