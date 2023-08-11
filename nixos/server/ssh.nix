{ config, lib, ... }:
let inherit (config.meta) username;
in
{
  options.nixos.server.ssh.enable = lib.mkEnableOption "SSH config";

  config = lib.mkIf config.nixos.server.ssh.enable {
    # Enable OpenSSH
    services = {
      fail2ban.enable = true;
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
        };
      };
    };

    # Enable mosh
    programs.mosh.enable = true;

    # Add SSH key
    users.extraUsers.${username}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2emux6tprbzXmtykaW44sSd4o7e7E2wAWZMFBSUb87 thiagokokada@gmail.com"
    ];
  };
}
