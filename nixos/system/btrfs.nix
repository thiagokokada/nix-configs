{ config, lib, pkgs, ... }:

{
  options.nixos.system.btrfs = {
    enable =
      let
        inherit (config.boot) initrd supportedFilesystems;
        inherit (lib) any;
        btrfsInInitrd = any (fs: fs == "btrfs") initrd.supportedFilesystems;
        btrfsInSystem = any (fs: fs == "btrfs") supportedFilesystems;
        default = btrfsInInitrd || btrfsInSystem;
      in
      lib.mkEnableOption "btrfs config" // { inherit default; };
  };

  config = lib.mkIf config.nixos.system.btrfs.enable {
    environment.systemPackages = with pkgs; [ compsize ];
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };
  };
}
