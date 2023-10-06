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
    zsh-system-clipboard = {
      url = "github:kutsan/zsh-system-clipboard";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      inherit (import ./lib/attrsets.nix { inherit (nixpkgs) lib; }) recursiveMergeAttrs;
      inherit (import ./lib/flake.nix inputs) mkGHActionsYAMLs mkRunCmd mkNixOSConfig mkHomeConfig;
    in
    (recursiveMergeAttrs [
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
        text = ''
          find . -name '*.nix' \
            ! -name 'hardware-configuration.nix' \
            ! -name 'cachix.nix' \
            ! -path './modules/home-manager/*' \
            ! -path './modules/nixos/*' \
            -exec nixpkgs-fmt --check {} \+
        '';
      })
      (mkRunCmd {
        name = "format";
        text = ''
          find . -name '*.nix' \
            ! -name 'hardware-configuration.nix' \
            ! -name 'cachix.nix' \
            ! -path './modules/home-manager/*' \
            ! -path './modules/nixos/*' \
            -exec nixpkgs-fmt {} \+
        '';
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
          # Needs to run with `--impure` flag because `builtins.getEnv`
          getEnvOrDefault = env: default:
            let envValue = builtins.getEnv env; in
            if envValue != "" then envValue else default;
          tmpdir = getEnvOrDefault "TMPDIR" "/tmp";
          homePath = "${tmpdir}/home";
          user = getEnvOrDefault "USER" "nobody";
          homeManager = (mkHomeConfig {
            inherit homePath system;
            configuration = ./home-manager/minimal.nix;
            hostname = "devShell";
            username =
              if user == "nobody"
              then
                (nixpkgs.lib.warn
                  "username is set to 'nobody', you may have forgot `--impure` flag!"
                  user)
              else user;
          }).homeConfigurations.devShell;
        in
        {
          devShells.default = pkgs.mkShell {
            shellHook = ''
              export HOME=${homeManager.config.home.homeDirectory}
              mkdir -p "$HOME"

              trap "rm -rf ${homePath}" EXIT

              ${homeManager.activationPackage}/activate
              . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

              zsh -l && exit 0
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
    ]); # END recursiveMergeAttrs
}
