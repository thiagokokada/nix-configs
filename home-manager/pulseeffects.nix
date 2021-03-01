{ config, lib, pkgs, ... }:

{
  services.pulseeffects = {
    enable = true;
    package = pkgs.unstable.pulseeffects-legacy;
  };
}
