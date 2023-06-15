{ pkgs, ... }:

{
  programs.htop = {
    enable = true;
    package = pkgs.htop-vim;
    settings = {
      hide_userland_threads = true;
      color_scheme = 6;
    };
  };
}
