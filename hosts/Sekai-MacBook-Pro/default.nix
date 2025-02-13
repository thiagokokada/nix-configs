{ flake, ... }:

{
  imports = [ flake.outputs.darwinModules.default ];

  meta.username = "thiago.okada";

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix-darwin.home.extraModules = [
    {
      home-manager = {
        darwin.remapKeys.mappings = {
          # '§±' <-> '`~'
          "0x700000035" = "0x700000064";
          "0x700000064" = "0x700000035";
        };
      };
    }
  ];

  # This value determines the nix-darwin release with which your system is to
  # be compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after nix-darwin release notes say you
  # should.
  system.stateVersion = 6; # Did you read the comment?
}
