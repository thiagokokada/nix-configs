{ config, lib, pkgs, inputs, system, ... }:

{
  imports = [ ./yubikey.nix ];

  nixpkgs.overlays = [ (import inputs.nubank) ];

  environment.systemPackages = with pkgs;
    [ nubank.dart nubank.flutter nubank.hover unstable.slack unstable.zoom-us ]
    ++ nubank.all-tools;

  # virtualisation = {
  #   # Enable VirtualBox.
  #   virtualbox.host.enable = true;
  # };

  # Added user to groups.
  # users.users.${config.my.username}.extraGroups = [ "vboxusers" ];
}
