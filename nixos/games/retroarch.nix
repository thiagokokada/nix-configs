{ pkgs, lib, config, ... }:

let
  cfg = config.nixos.games.retroarch;
in
{
  options.nixos.games.retroarch = {
    enable = lib.mkEnableOption "RetroArch config" // {
      default = config.nixos.games.enable;
    };
    package = lib.mkPackageOption pkgs "retroarch" {
      default = "retroarchFull";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    services.xserver.desktopManager.retroarch = {
      enable = true;
      package = cfg.package;
    };
  };
}
