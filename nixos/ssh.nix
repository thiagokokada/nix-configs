{ config, lib, pkgs, ... }:
let inherit (config.meta) username;
in
{
  # Enable OpenSSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  # Enable mosh
  programs.mosh.enable = true;

  # Add SSH key
  users.extraUsers.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2emux6tprbzXmtykaW44sSd4o7e7E2wAWZMFBSUb87 thiagokokada@gmail.com"
  ];
}
