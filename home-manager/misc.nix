{ config, lib, pkgs, super, ... }:

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
  ];

  # Add some Nix related packages
  home.packages = with pkgs; [
    nox
    nix-where-is
  ];

  # Set custom nixpkgs config (e.g.: allowUnfree), both for this
  # config and for ad-hoc nix commands invocation
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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
