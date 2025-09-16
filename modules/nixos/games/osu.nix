{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.nixos.games.osu;
in
{
  options.nixos.games.osu.enable = lib.mkEnableOption "osu! config";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ osu-lazer ];

    # Enable opentabletdriver
    hardware.opentabletdriver.enable = true;
  };
}
