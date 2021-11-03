{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    python3
    unstable.black
  ];
}
