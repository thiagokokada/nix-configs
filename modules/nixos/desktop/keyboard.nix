{
  config,
  lib,
  ...
}:

let
  cfg = config.nixos.desktop.keyboard;
in
{
  options.nixos.desktop.keyboard.enable = lib.mkEnableOption "Keyboard config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    nixos.home.extraModules = {
      home.keyboard = {
        inherit (config.services.xserver.xkb) layout variant;
        options = lib.splitString "," config.services.xserver.xkb.options;
      };
    };

    # Configure the virtual console keymap from the xserver keyboard settings
    console.useXkbConfig = true;

    services = {
      xserver = {
        xkb = {
          # X11 keyboard layout
          layout = lib.mkDefault "us";
          variant = lib.mkDefault "intl";
          # Remap Caps Lock to Esc, and use Super+Space to change layouts
          options = lib.mkDefault (
            lib.concatStringsSep "," [
              "caps:escape"
              "grp:win_space_toggle"
            ]
          );
        };
      };
    };
  };
}
