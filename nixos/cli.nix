{ config, pkgs, lib, ... }:

{
  options.nixos.cli.enable = lib.mkDefaultOption "CLI config";

  config = lib.mkIf config.nixos.cli.enable {
    # CLI packages.
    environment = {
      # To get zsh completion for system packages
      pathsToLink = [ "/share/zsh" ];

      systemPackages = with pkgs; with config.boot.kernelPackages; [
        cpupower
        glxinfo
        lm_sensors
        lshw
        pciutils
        powertop
        psmisc
        ryzenadj
        turbostat
        usbutils
      ];
    };

    # Enable programs that need special configuration.
    programs = {
      iftop.enable = true;
      mtr.enable = true;
      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        withRuby = false;
        withNodeJs = false;
      };
      traceroute.enable = true;
      zsh.enable = true;
    };
  };
}
