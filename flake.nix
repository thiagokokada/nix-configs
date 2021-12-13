{
  description = "My Nix{OS} configuration files";

  inputs = {
    # main
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
    home = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # helpers
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils/master";
    declarative-cachix.url = "github:jonascarpay/declarative-cachix/master";

    # nix-ld
    nix-ld = {
      url = "github:Mic92/nix-ld/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # nixpkgs-review
    nixpkgs-review = {
      url = "github:thiagokokada/nixpkgs-review/add-bubblewrap-sandbox";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    # overlays
    emacs = {
      url = "github:nix-community/emacs-overlay/master";
      inputs.nixpkgs.follows = "unstable";
    };
    nubank.url = "github:nubank/nixpkgs/master";

    # htop-vim
    htop-vim = {
      url = "github:KoffeinFlummi/htop-vim/master";
      flake = false;
    };

    # nnn plugins
    nnn-plugins = {
      url = "github:jarun/nnn/v4.0";
      flake = false;
    };

    # ZSH plugins
    zit = {
      url = "github:thiagokokada/zit/master";
      flake = false;
    };
    zim-completion = {
      url = "github:zimfw/completion/master";
      flake = false;
    };
    zim-environment = {
      url = "github:zimfw/environment/master";
      flake = false;
    };
    zim-input = {
      url = "github:zimfw/input/master";
      flake = false;
    };
    zim-git = {
      url = "github:zimfw/git/master";
      flake = false;
    };
    zim-ssh = {
      url = "github:zimfw/ssh/master";
      flake = false;
    };
    zim-utility = {
      url = "github:zimfw/utility/master";
      flake = false;
    };
    pure = {
      url = "github:sindresorhus/pure/main";
      flake = false;
    };
    zsh-autopair = {
      url = "github:hlissner/zsh-autopair/master";
      flake = false;
    };
    zsh-completions = {
      url = "github:zsh-users/zsh-completions/master";
      flake = false;
    };
    zsh-history-substring-search = {
      url = "github:zsh-users/zsh-history-substring-search/master";
      flake = false;
    };
    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting/master";
      flake = false;
    };
    zsh-system-clipboard = {
      url = "github:kutsan/zsh-system-clipboard/master";
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
        mkSystem = { modules, system ? "x86_64-linux" }:
          nixpkgs.lib.nixosSystem {
            inherit system modules;
            specialArgs = { inherit self system; };
          };
      in
      {
        miku-nixos = mkSystem { modules = [ ./hosts/miku-nixos ]; };

        mikudayo-nixos = mkSystem { modules = [ ./hosts/mikudayo-nixos ]; };

        mikudayo-nubank = mkSystem { modules = [ ./hosts/mikudayo-nubank ]; };

        mirai-vps = mkSystem { modules = [ ./hosts/mirai-vps ]; };
      };

    darwinConfigurations =
      let
        mkDarwin = { modules, system ? "x86_64-darwin" }:
          nix-darwin.lib.darwinSystem {
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
          }:
          home.lib.homeManagerConfiguration rec {
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
