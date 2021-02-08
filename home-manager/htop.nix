{ config, lib, pkgs, ... }:

{
  programs.htop = {
    enable = true;
    treeView = true;
    hideUserlandThreads = true;
    # Disabled from now, may come back later on
    # https://github.com/htop-dev/htop/pull/141
    # vimMode = true;
  };
}
