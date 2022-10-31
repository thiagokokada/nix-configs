{ config, lib, pkgs, flake, ... }:

let inherit (config.home) username;
in
{
  programs.firefox = {
    enable = true;
    profiles.${username} = {
      settings = {
        "browser.quitShortcut.disabled" = true;
      };
    };
  };
}
