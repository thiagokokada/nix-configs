{ config, lib, pkgs, ... }:

{
  options.nixos.system.btrfs = {
    enable =
      let
        inherit (config.boot) initrd supportedFilesystems;
        btrfsInInitrd = builtins.elem "btrfs" initrd.supportedFilesystems;
        btrfsInSystem = builtins.elem "brtfs" supportedFilesystems;
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
