{ pkgs, lib, inputs, ... }:

{
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
