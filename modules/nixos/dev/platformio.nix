{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.nixos.home) username;
  cfg = config.nixos.dev.platformio;
in
{
  options.nixos.dev.platformio = {
    enable = lib.mkEnableOption "PlatformIO developer config";
  };

  config = lib.mkIf cfg.enable {
    # Needed for Crosspoint development
    services.udev.packages = with pkgs; [ platformio-core.udev ];
    users.users.${username}.extraGroups = [ "dialout" ];
  };
}
