{ lib, pkgs, flake, ... }:

{
  imports = [
    ../cachix.nix
    ../overlays
  ];

  # Add some Nix related packages
  environment.systemPackages = with pkgs; [
    nixos-cleanup
    nom-rebuild
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = lib.mkDefault "23.11"; # Did you read the comment?

  nix = import ../shared/nix.nix { inherit pkgs flake; };

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Change build dir to /var/tmp
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };
}
