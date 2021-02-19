{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnupg
    libu2f-host
    yubikey-manager
    yubikey-personalization-gui
  ];

  programs.gnupg.agent.enable = true;

  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [ libu2f-host yubikey-personalization ];
  };
}
