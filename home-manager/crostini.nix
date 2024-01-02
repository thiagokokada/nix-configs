{ config, lib, libEx, pkgs, ... }:

{
  options.home-manager.crostini.enable = lib.mkEnableOption "Crostini (ChromeOS) config";

  config = lib.mkIf config.home-manager.crostini.enable {
    home.packages = with pkgs; [
      nixgl.nixGLMesa
      (libEx.nixGLWrapper { pkg = firefox; nixGL = nixgl.nixGLMesa; })
    ];

    home-manager = {
      # Not using the desktop.firefox here since we are wrapping it with
      # nixGLWrapper, that it is incompatible with the Home-Manager
      # module
      desktop.mpv.enable = lib.mkDefault true;
      dev.enable = lib.mkDefault true;
      editor.neovim.enableLowMemory = lib.mkDefault true;
    };

    programs = {
      mpv.package = libEx.nixGLWrapper {
        pkg = pkgs.mpv;
        nixGL = pkgs.nixgl.nixGLMesa;
      };
    };

    # https://nixos.wiki/wiki/Installing_Nix_on_Crostini
    xdg.configFile."systemd/user/cros-garcon.service.d/override.conf".text = ''
      [Service]
      Environment="PATH=%h/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/local/games:/usr/sbin:/usr/bin:/usr/games:/sbin:/bin"
      Environment="XDG_DATA_DIRS=%h/.nix-profile/share:%h/.local/share:/usr/local/share:/usr/share"
    '';
  };
}
