{ osConfig, ... }:

{
  imports = [
    ./default.nix
  ];

  home-manager = {
    desktop.enable = osConfig.nixos.desktop.enable;
    dev.enable = osConfig.nixos.dev.enable;
  };

  targets.genericLinux.enable = false;
}
