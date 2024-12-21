{ flake, ... }:

{
  imports = [ flake.outputs.darwinModules.default ];

  mainUser.username = "thiago.okada";

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.keyboard = {
    enableKeyMapping = true;
    nonUS.remapTilde = true;
  };

  # This value determines the nix-darwin release with which your system is to
  # be compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after nix-darwin release notes say you
  # should.
  system.stateVersion = 4; # Did you read the comment?
}
