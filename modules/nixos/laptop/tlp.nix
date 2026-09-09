{ config, lib, ... }:

let
  cfg = config.nixos.laptop.tlp;
in
{
  options.nixos.laptop.tlp = {
    enable = lib.mkEnableOption "TLP config" // {
      default = !config.services.power-profiles-daemon.enable && config.nixos.laptop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;
      pd.enable = true;
    };
  };
}
