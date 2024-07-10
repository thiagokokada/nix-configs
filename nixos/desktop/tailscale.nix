{ config, lib, ... }:

{
  options.nixos.desktop.tailscale.enable = lib.mkEnableOption "Tailscale config (client side)" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = if config.nixos.server.tailscale.enable then "both" else "client";
    };
  };
}
