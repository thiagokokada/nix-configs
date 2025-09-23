{ config, lib, ... }:

let
  inherit (config.nixos.home) username;
  cfg = config.nixos.server.ssh;
in
{
  options.nixos.server.ssh = {
    enable = lib.mkEnableOption "SSH config";
    authorizedKeys = lib.mkOption {
      description = "List of authorized keys.";
      type = lib.types.listOf lib.types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2emux6tprbzXmtykaW44sSd4o7e7E2wAWZMFBSUb87 thiagokokada@gmail.com"
      ];
    };
    root.enableLogin = lib.mkEnableOption "root login via SSH";
  };

  config = lib.mkIf cfg.enable {
    # Enable OpenSSH
    services.openssh = {
      enable = true;
      ports = [
        22
        2222
      ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    # Enable mosh
    programs.mosh.enable = true;

    # Add SSH key
    users.users.root.openssh.authorizedKeys.keys = lib.mkIf cfg.root.enableLogin cfg.authorizedKeys;
    users.extraUsers.${username}.openssh.authorizedKeys.keys = cfg.authorizedKeys;
  };
}
