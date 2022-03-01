{
  description = "My Nix{OS} configuration files";

  inputs = {
    # main
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hardware.url = "github:NixOS/nixos-hardware";
    home = {
      url = "github:nix-community/home-manager/release-21.11";
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

    # helpers
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    declarative-cachix.url = "github:jonascarpay/declarative-cachix";

    # nix-alien
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # nixpkgs-review
    nixpkgs-review = {
      url = "github:Mic92/nixpkgs-review";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    # envfs
    envfs = {
      url = "github:Mic92/envfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    # overlays
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

    # nnn plugins
    nnn-plugins = {
      url = "github:jarun/nnn/v4.4";
      flake = false;
    };

    # ZSH plugins
    zit = {
      url = "github:thiagokokada/zit";
      flake = false;
    };
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

  outputs = { self, nixpkgs, unstable, nix-darwin, home, flake-utils, ... }: {
    defaultTemplate = self.templates.new-host;

    templates.new-host = {
      path = ./templates/new-host;
      description = "Create a new host";
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
            stateVersion = "21.11";
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
    in
    {
      devShell = with pkgs; mkShell {
        buildInputs = [
          coreutils
          findutils
          gnumake
          nix_2_4
          nixpkgs-fmt
        ];
      };
    }
  );
}
