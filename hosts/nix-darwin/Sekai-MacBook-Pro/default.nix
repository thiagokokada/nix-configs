{
  meta.username = "thiago.okada";

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix-darwin.home.extraModules = [
    {
      home.stateVersion = "24.05";
      home-manager = {
        editor.idea.enable = true;
      };
    }
  ];

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
    nonUS.remapTilde = true;
  };

  # This value determines the nix-darwin release with which your system is to
  # be compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after nix-darwin release notes say you
  # should.
  system.stateVersion = 6; # Did you read the comment?
}
