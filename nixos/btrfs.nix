{ config, lib, pkgs, ... }:

let
  inherit (config.boot) initrd supportedFilesystems;
  inherit (lib) any mkIf;
  btrfsInInitrd = any (fs: fs == "btrfs") initrd.supportedFilesystems;
  btrfsInSystem = any (fs: fs == "btrfs") supportedFilesystems;
  enable = btrfsInInitrd || btrfsInSystem;
in
{
  environment.systemPackages = with pkgs; lib.optionals enable [ compsize ];
  services.btrfs.autoScrub = {
    inherit enable;
    interval = "weekly";
  };
}
