{ config, lib, pkgs, super, self, ... }:

let
  videoDrivers = super.services.xserver.videoDrivers or [ ];
  backend =
    if (builtins.elem "nvidia" videoDrivers)
    then "xrender"
    else "glx";
in
{
  # TODO: remove this once this PR is merged:
  # https://github.com/nix-community/home-manager/pull/2887
  disabledModules = [ "services/picom.nix" ];
  imports = [ "${self.inputs.home-picom-fix}/modules/services/picom.nix" ];

  services.picom = {
    inherit backend;
    enable = config.device.type != "vm";
    package = pkgs.unstable.picom-next;
    experimentalBackends = true;
    fade = true;
    fadeDelta = 2;
    vSync = true;
    extraOptions = ''
      unredir-if-possible = true;
      unredir-if-possible-exclude = [ "name *= 'Firefox'" ];
    '';
  };
}
