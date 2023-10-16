{ config, lib, ... }:

let
  inherit (config.mainUser) username;
  cfg = config.nixos.server.ssh;
in
{
  options.nixos.server.ssh = {
    enable = lib.mkEnableOption "SSH config";
    enableRootLogin = lib.mkEnableOption "Root login via SSH";
    authorizedKeys = lib.mkOption {
      description = "List of authorized keys.";
      type = lib.types.listOf lib.types.str;
      default = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2emux6tprbzXmtykaW44sSd4o7e7E2wAWZMFBSUb87 thiagokokada@gmail.com" ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable OpenSSH
    services = {
      fail2ban.enable = true;
      openssh = {
        enable = true;
        ports = [ 22 2222 ];
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
    };

    # Enable mosh
    programs.mosh.enable = true;

    # Add SSH key
    users.users.root.openssh.authorizedKeys.keys = lib.mkIf cfg.enableRootLogin cfg.authorizedKeys;
    users.extraUsers.${username}.openssh.authorizedKeys.keys = cfg.authorizedKeys;
  };
}
