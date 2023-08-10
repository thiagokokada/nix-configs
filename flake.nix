{
  description = "My Nix{OS} configuration files";

  inputs = {
    # main
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";
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

  outputs = { self, nixpkgs, ... }@inputs:
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

      # Home-Manager configs
      (mkHomeConfig { hostname = "home-linux"; })
      (mkHomeConfig {
        hostname = "home-linux-minimal";
        configuration = ./home-manager/minimal.nix;
      })
      (mkHomeConfig {
        hostname = "steamdeck";
        username = "deck";
        configuration = ./home-manager/steamdeck.nix;
      })
      (mkHomeConfig {
        hostname = "home-macos";
        configuration = ./home-manager/macos.nix;
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
      ])
    ]); # END recursiveMergeAttrs
}
