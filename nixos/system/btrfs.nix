{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos.system.btrfs = {
    enable =
      let
        inInitrd = config.boot.initrd.supportedFilesystems.btrfs or false;
        inSystem = config.boot.supportedFilesystems.btrfs or false;
        default = inInitrd || inSystem;
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
