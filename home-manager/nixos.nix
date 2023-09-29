{ osConfig, ... }:

{
  imports = [
    ./default.nix
  ];

  home-manager = {
    desktop.enable = (osConfig.nixos.desktop.enable or false);
    dev = {
      clojure.enable = true;
      go.enable = true;
      node.enable = true;
      python.enable = true;
    };
  };
}
