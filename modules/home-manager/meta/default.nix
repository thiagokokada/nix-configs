{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.meta;
in
{
  imports = [
    ./diff.nix
    ./restore-backups.nix
  ];

  options.home-manager.meta = {
    enable = lib.mkEnableOption "Home-Manager config" // {
      default = true;
    };
    autoExpire.enable = lib.mkEnableOption "auto expire Home-Manager generations" // {
      default = pkgs.stdenv.isLinux;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      # Let Home Manager install and manage itself
      home-manager.enable = true;
      # Without git we may be unable to build this config
      git.enable = true;
    };

    services.home-manager.autoExpire = {
      inherit (cfg.autoExpire) enable;
      timestamp = "-7 days";
      frequency = "3:05";
      store.cleanup = true;
    };

    # More reliable user service restart
    systemd.user.startServices = lib.mkDefault "sd-switch";
  };
}
