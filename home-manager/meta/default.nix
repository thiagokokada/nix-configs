{ lib, pkgs, self, super, ... }:

let
  inherit (self) inputs;
in
{
  # Import overlays
  imports = [
    ../../overlays
    ../../modules/device.nix
    ../../modules/meta.nix
    inputs.declarative-cachix.homeManagerModules.declarative-cachix-experimental
  ];

  # Add some Nix related packages
  home.packages = with pkgs; [
    hydra-check
    nix-update
    nix-whereis
    nixpkgs-fmt
    nixpkgs-review
  ];

  # Add nix.conf for the standalone installations of HM
  # Need to use `home.file.nixConf`, otherwise conflicts with declarative-nix
  # will happen
  # TODO: remove once https://github.com/nix-community/home-manager/issues/2324
  # is fixed
  home.file.nixConf = {
    target = ".config/nix/nix.conf";
    text = builtins.readFile ../../shared/nix.conf;
  };

  # To make cachix work you need add the current user as a trusted-user on Nix
  # sudo echo "trusted-users = $(whoami)" >> /etc/nix/nix.conf
  # Another option is to add a group by prefixing it by @, e.g.:
  # sudo echo "trusted-users = @wheel" >> /etc/nix/nix.conf
  caches.cachix = [
    { name = "nix-community"; sha256 = "00lpx4znr4dd0cc4w4q8fl97bdp7q19z1d3p50hcfxy26jz5g21g"; }
    { name = "thiagokokada-nix-configs"; sha256 = "01kzz81ab24a2z0lf0rfjly8k8kgxr7p0x8b7xai3hzakmbmb6nx"; }
  ];

  # Set custom nixpkgs config (e.g.: allowUnfree), both for this
  # config and for ad-hoc nix commands invocation
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # Without git we may be unable to build this config
    git.enable = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # Inherit config from NixOS or homeConfigurations
  device = super.device;
  meta = super.meta;
}
