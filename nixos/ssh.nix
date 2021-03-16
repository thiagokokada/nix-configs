{ config, lib, pkgs, ... }:

{
  # Enable OpenSSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
}
