{ lib, ... }:

rec {
  isNvidia = osConfig:
    let
      videoDrivers = osConfig.services.xserver.videoDrivers or [ ];
    in
    builtins.elem "nvidia" videoDrivers;

  shortPathWithSep = with lib.strings;
    (sep: path: concatStringsSep sep (map (substring 0 1) (splitString "/" path)));

  shortPath = shortPathWithSep "/";
}
