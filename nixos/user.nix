{ config, lib, pkgs, ... }:
let
  inherit (config.meta) username;
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.zsh;
    password = "changeme";
  };
}
