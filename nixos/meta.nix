{ config, pkgs, self, ... }:

{
  imports = [ ../cachix.nix ];

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
      # Git 2.35.2 added a check for directories from a different owner, e.g.:
      # fatal: unsafe repository ('/etc/nixos' is owned by someone else)
      # This creates an exception just for the config path
      safe.directory = config.meta.configPath;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?

  nix = import ../shared/nix.nix { inherit pkgs self; };

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;
}
