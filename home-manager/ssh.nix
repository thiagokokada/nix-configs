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
  };
}
