{
  description = "My Nix{OS} configuration files";

  inputs = {
    # main
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";
    home = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-compat.follows = "flake-compat";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # nixpkgs-review
    nixpkgs-review = {
      url = "github:Mic92/nixpkgs-review";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    # overlays
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    # nnn plugins
    nnn-plugins = {
      url = "github:jarun/nnn/v4.4";
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

  outputs = { self, nixpkgs, unstable, nix-darwin, home, home-unstable, flake-utils, ... }: {
    templates = rec {
      default = new-host;
      new-host = {
        path = ./templates/new-host;
        description = "Create a new host";
      };
    };

    nixosConfigurations =
      let
        mkSystem =
          { modules
          , system ? "x86_64-linux"
          , nixosSystem ? nixpkgs.lib.nixosSystem
          }:
          nixosSystem {
            inherit system modules;
            specialArgs = { inherit self system; };
          };
      in
      {
        miku-nixos = mkSystem { modules = [ ./hosts/miku-nixos ]; };

        mikudayo-re-nixos = mkSystem { modules = [ ./hosts/mikudayo-re-nixos ]; };

        miku-vm = mkSystem { modules = [ ./hosts/miku-vm ]; };

        mirai-vps = mkSystem { modules = [ ./hosts/mirai-vps ]; };
      };

    darwinConfigurations =
      let
        mkDarwin =
          { modules
          , system ? "x86_64-darwin"
          , darwinSystem ? nix-darwin.lib.darwinSystem
          }:
          darwinSystem {
            inherit system modules;
            specialArgs = { inherit self system; };
          };
      in
      {
        miku-macos-vm = mkDarwin { modules = [ ./hosts/miku-macos-vm ]; };
      };

    # https://github.com/nix-community/home-manager/issues/1510
    homeConfigurations =
      let
        mkHome =
          { username ? "thiagoko"
          , homePath ? "/home"
          , configPosfix ? "Projects/nix-configs"
          , configuration ? ./home-manager
          , deviceType ? "desktop"
          , system ? "x86_64-linux"
          , homeManagerConfiguration ? home.lib.homeManagerConfiguration
          }:
          homeManagerConfiguration rec {
            inherit configuration username system;
            homeDirectory = "${homePath}/${username}";
            stateVersion = "22.05";
            extraSpecialArgs = {
              inherit self system;
              super = {
                device.type = deviceType;
                meta.username = username;
                meta.configPath = "${homeDirectory}/${configPosfix}";
              };
            };
          };
      in
      {
        home-linux = mkHome { };

        home-macos = mkHome {
          configuration = ./home-manager/macos.nix;
          system = "x86_64-darwin";
          homePath = "/Users";
        };
      };
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      buildGHActionsYAML = name:
        let
          file = import (./actions + "/${name}.nix");
          json = builtins.toJSON file;
        in
        {
          ${name} = pkgs.writeShellScriptBin name ''
            echo ${pkgs.lib.escapeShellArg json} | ${pkgs.yj}/bin/yj -jy;
          '';
        };
    in
    {
      githubActions =
        (buildGHActionsYAML "build-and-cache") //
          (buildGHActionsYAML "update-flakes") //
          (buildGHActionsYAML "update-flakes-darwin");

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          coreutils
          findutils
          gnumake
          nixpkgs-fmt
          nixUnstable
        ];
      };
    }
  );
}
