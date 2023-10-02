{ config, lib, ... }:

let
  cfg = config.nixos.desktop.ssh;
in
{
  options.nixos.desktop.ssh.enable = lib.mkEnableOption "SSH config (client side)" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enableAskPassword = true;
      forwardX11 = true;
    };
  };
}
