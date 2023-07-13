{ lib, pkgs, osConfig, ... }:

{
  # Import overlays
  imports = [
    ../../overlays
    ../../modules/device.nix
    ../../modules/meta.nix
  ];

  # Inherit config from NixOS or homeConfigurations
  inherit (osConfig) device meta;

  # Add some Nix related packages
  home.packages = with pkgs; [
    home-manager
    hydra-check
    nix-cleanup
    nix-update
    nix-whereis
    nixpkgs-fmt
  ];

  # To make cachix work you need add the current user as a trusted-user on Nix
  # sudo echo "trusted-users = $(whoami)" >> /etc/nix/nix.conf
  # Another option is to add a group by prefixing it by @, e.g.:
  # sudo echo "trusted-users = @wheel" >> /etc/nix/nix.conf
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = import ../../shared/nix-conf.nix // {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://thiagokokada-nix-configs.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "thiagokokada-nix-configs.cachix.org-1:MwFfYIvEHsVOvUPSEpvJ3mA69z/NnY6LQqIQJFvNwOc="
      ];
    };
  };

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
  home.stateVersion = (osConfig.system.stateVersion or "23.11");

  manual.html.enable = true;
}
