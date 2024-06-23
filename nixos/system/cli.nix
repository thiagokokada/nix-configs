{ config, pkgs, lib, ... }:

{
  options.nixos.system.cli.enable = lib.mkEnableOption "CLI config" // {
    default = config.nixos.system.enable;
  };

  config = lib.mkIf config.nixos.system.cli.enable {
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
        usbutils
      ] ++ lib.optionals stdenv.isx86_64 [
        ryzenadj
        turbostat
      ];
    };

    # Enable programs that need special configuration.
    programs = {
      git = {
        # Without git we may be unable to build this config
        enable = true;
        config = {
          # Avoid git log spam while building this config
          init.defaultBranch = "master";
        };
      };
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
      zsh = {
        enable = true;
        # Will be set by zim-completion
        enableCompletion = false;
      };
    };
  };
}
