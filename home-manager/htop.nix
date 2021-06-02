{ config, lib, pkgs, ... }:

{
  programs.htop = {
    enable = true;
    settings = {
      hide_userland_threads = true;
    };
  };
}
