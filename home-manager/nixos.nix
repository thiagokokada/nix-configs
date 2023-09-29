{ osConfig, lib, ... }:

{
  imports = [
    ./default.nix
  ];

  home-manager = {
    desktop.enable = osConfig.nixos.desktop.enable;
    dev = lib.mkIf osConfig.nixos.dev.enable {
      clojure.enable = lib.mkDefault true;
      go.enable = lib.mkDefault true;
      node.enable = lib.mkDefault true;
      python.enable = lib.mkDefault true;
    };
  };
}
