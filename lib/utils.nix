{ ... }:

{
  isNvidia = osConfig:
    let
      videoDrivers = osConfig.services.xserver.videoDrivers or [ ];
    in
    (builtins.elem "nvidia" videoDrivers);
}
