{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  cfg = config.home-manager.meta;
in
{
  imports = [
    ./home-manager-auto-expire.nix
    ./diff.nix
  ];

  options.home-manager.meta = {
    enable = lib.mkEnableOption "Home-Manager config" // {
      default = true;
    };
    autoExpire.enable = lib.mkEnableOption "auto expire Home-Manager generations" // {
      default = pkgs.stdenv.isLinux;
    };
    sdSwitch.enable = lib.mkEnableOption "more reliable user service restart" // {
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

    services.home-manager.autoExpire = lib.mkIf cfg.autoExpire.enable {
      enable = true;
      timestamp = "-7 days";
      frequency = "3:05";
      store.cleanup = true;
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = osConfig.system.stateVersion or "24.05";

    # More reliable user service restart
    systemd.user.startServices = lib.mkIf cfg.sdSwitch.enable "sd-switch";

    manual.html.enable = true;
  };
}
