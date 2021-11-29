{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    black
    python3
  ];
}
