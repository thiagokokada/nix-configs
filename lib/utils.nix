{ lib, ... }:

{
  isNvidia = super:
    let
      videoDrivers = super.services.xserver.videoDrivers or [ ];
    in
    (builtins.elem "nvidia" videoDrivers);
}
