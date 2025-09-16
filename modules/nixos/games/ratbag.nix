{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.nixos.games.ratbag;
in
{
  options.nixos.games.ratbag.enable =
    lib.mkEnableOption "Ratbag/Piper (e.g. Logitech devices) config";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ piper ];

    # Enable ratbagd (i.e.: piper) for Logitech devices
    services.ratbagd.enable = true;
  };
}
