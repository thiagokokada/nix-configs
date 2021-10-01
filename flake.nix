{
  description = "My Nix{OS} configuration files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
    home = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay/master";
      inputs.nixpkgs.follows = "unstable";
    };
    nubank.url = "github:nubank/nixpkgs/master";

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
    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting/master";
      flake = false;
    };
    zsh-history-substring-search = {
      url = "github:zsh-users/zsh-history-substring-search/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home, ... }@inputs: {
    nixosConfigurations = {
      miku-nixos = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ ./hosts/miku-nixos ];
        specialArgs = { inherit inputs system; };
      };

      mikudayo-nixos = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ ./hosts/mikudayo-nixos ];
        specialArgs = { inherit inputs system; };
      };

      mikudayo-nubank = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ ./hosts/mikudayo-nubank ];
        specialArgs = { inherit inputs system; };
      };

      mirai-vps = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ ./hosts/mirai-vps ];
        specialArgs = { inherit inputs system; };
      };
    };

    # https://github.com/nix-community/home-manager/issues/1510
    homeConfigurations = {
      home-linux = home.lib.homeManagerConfiguration rec {
        configuration = ./home-manager;
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        username = "thiagoko";
        extraSpecialArgs = {
          inherit inputs system;
          super = {
            device.type = "desktop";
            meta.username = username;
            meta.configPath = "${homeDirectory}/Projects/nix-configs";
          };
        };
      };

      home-macos = home.lib.homeManagerConfiguration rec {
        configuration = {
          imports = [
            ./home-manager/cli.nix
            ./home-manager/emacs.nix
            ./home-manager/git.nix
            ./home-manager/htop.nix
            ./home-manager/misc.nix
            ./home-manager/neovim.nix
            ./home-manager/ssh.nix
            ./home-manager/tmux.nix
            ./home-manager/zsh.nix
          ];
        };
        system = "x86_64-darwin";
        homeDirectory = "/Users/${username}";
        username = "thiagoko";
        extraSpecialArgs = {
          inherit inputs system;
          super = {
            device.type = "desktop";
            meta.username = username;
            meta.configPath = "${homeDirectory}/Projects/nix-configs";
          };
        };
      };
    };
  };
}
