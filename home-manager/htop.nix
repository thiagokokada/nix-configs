{ config, lib, pkgs, ... }:

{
  programs.htop = {
    enable = true;
    package = pkgs.htop-vim;
    settings = {
      hide_userland_threads = true;
    };
  };
}
