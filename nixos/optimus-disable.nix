{ config, lib, pkgs, ... }:

{
  # Disable Nvidia GPU to reduce power consumption
  hardware.nvidiaOptimus.disable = true;
}
