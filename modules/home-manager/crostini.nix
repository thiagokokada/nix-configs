{ config, lib, ... }:

{
  options.home-manager.crostini.enable = lib.mkEnableOption "Crostini (ChromeOS) config";

  config = lib.mkIf config.home-manager.crostini.enable {
    home-manager = {
      cli.git.gui.enable = true;
      desktop.mpv.enable = true;
      dev.enable = true;
    };

    nixGL = {
      defaultWrapper = "mesa";
      installScripts = [ "mesa" ];
    };

    # https://nixos.wiki/wiki/Installing_Nix_on_Crostini
    xdg.configFile."systemd/user/cros-garcon.service.d/override.conf".text =
      lib.generators.toINI { listsAsDuplicateKeys = true; }
        {
          Service = {
            Environment = [
              "PATH=${
                lib.concatStringsSep ":" [
                  "${config.home.profileDirectory}/bin"
                  "/usr/local/sbin"
                  "/usr/local/bin"
                  "/usr/local/games"
                  "/usr/sbin"
                  "/usr/bin"
                  "/usr/games"
                  "/sbin"
                  "/bin"
                ]
              }"
              "XDG_DATA_DIRS=${
                lib.concatStringsSep ":" [
                  "${config.home.profileDirectory}/share"
                  "%h/.local/share"
                  "%h/.local/share/flatpak/exports/share"
                  "/var/lib/flatpak/exports/share"
                  "/usr/local/share"
                  "/usr/share"
                ]
              }"
            ];
          };
        };
  };
}
