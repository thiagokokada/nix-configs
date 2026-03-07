{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.nixos.home) username;
  cfg = config.nixos.dev.android;
in
{
  options.nixos.dev.android = {
    enable = lib.mkEnableOption "Android developer config" // {
      default = config.nixos.dev.enable;
    };
    studio.enable = lib.mkEnableOption "Android Studio";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        android-tools
      ]
      ++ lib.optionals cfg.studio.enable [
        android-studio
      ];

    nixpkgs.config.android_sdk.accept_license = cfg.studio.enable;

    # Added user to groups
    users.users.${username}.extraGroups = [ "adbusers" ];
  };
}
