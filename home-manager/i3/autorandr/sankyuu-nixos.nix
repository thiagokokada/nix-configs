{ config, lib, pkgs, ... }:

{
  programs.autorandr.profiles =
    let
      fingerprint = {
        eDP-1 = "00ffffffffffff0030e4fa0500000000001c0104a51f117802aa95955e598e271b5054000000010101010101010101010101010101012e3680a070381f403020350035ae1000001ab62c80f4703816403020350035ae1000001a000000fe004c4720446973706c61790a2020000000fe004c503134305746412d53504432004d";
      };
    in
    {
      undocked = {
        inherit fingerprint;
        config.eDP-1 = {
          enable = true;
          primary = true;
          mode = "1920x1080";
          rate = "60.2";
        };
      };
    };
}
