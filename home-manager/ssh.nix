{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    compression = true;
    forwardAgent = true;
    serverAliveCountMax = 2;
    serverAliveInterval = 300;
    extraConfig = ''
      AddKeysToAgent yes
    '';
    matchBlocks = {
      "github.com" = {
        identityFile = with config.home; "${homeDirectory}/.ssh/github";
      };
    };
  };
}
