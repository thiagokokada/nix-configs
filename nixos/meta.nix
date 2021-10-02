{ pkgs, lib, inputs, ... }:

let
  nixos-clean-up = pkgs.writeShellScriptBin "nixos-clean-up" ''
    set -euo pipefail

    sudo -s -- <<EOF
    find -H /nix/var/nix/gcroots/auto -type l | xargs readlink | grep "/result$" | xargs rm -f
    nix-collect-garbage -d
    nixos-rebuild boot --fast
    if [[ "''${1:-}" == "--optimize" ]]; then
      nix-store --optimize
    fi
    EOF
  '';
in
{
  # TODO: remove on 21.11
  imports = [ "${inputs.unstable}/nixos/modules/programs/git.nix" ];

  # Add wheel to Nix trusted users
  nix.trustedUsers = [ "root" "@wheel" ];

  # Add some Nix related packages
  environment.systemPackages = with pkgs; [
    cachix
    nixos-clean-up
  ];

  programs.git = {
    # Without git we may be unable to build this config
    enable = true;
    config = {
      # Avoid git log spam while building this config
      init.defaultBranch = "master";
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05"; # Did you read the comment?

  nix = {
    # Enable Flakes
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Set the $NIX_PATH entry for nixpkgs. This is necessary in
    # this setup with flakes, otherwise commands like `nix-shell
    # -p pkgs.htop` will keep using an old version of nixpkgs
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # Same as above, but for `nix shell nixpkgs#htop`
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;
}
