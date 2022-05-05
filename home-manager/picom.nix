{ config, lib, pkgs, super, self, ... }:

let
  videoDrivers = super.services.xserver.videoDrivers or [ ];
  backend =
    if (builtins.elem "nvidia" videoDrivers)
    then "xrender"
    else "glx";
in
{
  # TODO: remove this once HM 22.05 is released
  disabledModules = [
    "services/compton.nix"
    "services/picom.nix"
  ];
  imports = [ "${self.inputs.home-fork}/modules/services/picom.nix" ];

  services.picom = {
    inherit backend;
    enable = config.device.type != "vm";
    package = pkgs.unstable.picom-next;
    experimentalBackends = true;
    fade = true;
    fadeDelta = 2;
    vSync = true;
    settings = {
      unredir-if-possible = true;
      unredir-if-possible-exclude = [ "name *= 'Firefox'" ];
    };
  };
}
