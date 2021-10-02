{ lib, pkgs, super, inputs, ... }:

let
  nix-where-is = pkgs.writeShellScriptBin "nix-where-is" ''
    set -euo pipefail

    readonly program_name="''${1:-}"

    if [[ -z "''${program_name}" ]]; then
      echo "usage: $(basename ''${0}) PROGRAM"
      exit 1
    fi

    readonly symbolic_link="$(which "''${program_name}")"
    readlink -f "''${symbolic_link}"
  '';
in
{
  # Import overlays
  imports = [
    ../overlays
    ../modules/device.nix
    ../modules/meta.nix
    inputs.declarative-cachix.homeManagerModules.declarative-cachix
  ];

  # Add some Nix related packages
  home.packages = with pkgs; [
    hydra-check
    nix-update
    nix-where-is
    nixpkgs-fmt
    nixpkgs-review
    nox
  ];

  # To make cachix work you need add the current user as a trusted-user on Nix
  # sudo echo "trusted-users = $(whoami)" >> /etc/nix/nix.conf
  # Another option is to add a group by prefixing it by @, e.g.:
  # sudo echo "trusted-users = @wheel" >> /etc/nix/nix.conf
  caches.cachix = [
    { name = "nix-community"; sha256 = "1r0dsyhypwqgw3i5c2rd5njay8gqw9hijiahbc2jvf0h52viyd9i"; }
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
  home.stateVersion = lib.mkForce "21.05";

  # Inherit config from NixOS or homeConfigurations
  device = super.device;
  meta = super.meta;
}
