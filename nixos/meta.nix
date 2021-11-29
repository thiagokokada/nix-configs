{ pkgs, self, ... }:

{
  # Add some Nix related packages
  environment.systemPackages = with pkgs; [
    cachix
    nixos-cleanup
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

  nix = import ../shared/nix.nix { inherit pkgs self; };

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;
}
