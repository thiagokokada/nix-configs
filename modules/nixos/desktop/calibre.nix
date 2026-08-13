{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos.desktop.calibre.enable = lib.mkEnableOption "Calibre config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.calibre.enable {
    environment.systemPackages = with pkgs; [
      calibre
    ];

    # Calibre server
    networking.firewall = {
      allowedTCPPorts = [ 9090 ];
      allowedUDPPorts = [
        54982
        48123
        39001
        44044
        59678
      ];
    };
  };
}
