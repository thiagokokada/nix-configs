{ config, lib, pkgs, ... }:

{
  # Enable OpenSSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  # Enable mosh
  programs.mosh.enable = true;
}
