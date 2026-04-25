{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.nixos.system.cli.enable = lib.mkEnableOption "CLI config" // {
    default = config.nixos.system.enable;
  };

  config = lib.mkIf config.nixos.system.cli.enable {
    nixos.home.extraModules = {
      programs = {
        man.package = null;
        # mandoc doesn't expand columns by default
        zsh.initContent =
          # bash
          ''
            man() {
              ${lib.getExe pkgs.mandoc} -O width="$(${lib.getExe' pkgs.ncurses "tput"} cols)" "$@"
            }
          '';
      };
    };

    # https://github.com/NixOS/nixpkgs/issues/513348
    documentation.man = {
      cache.enable = true;
      man-db.enable = false;
      mandoc.enable = true;
    };

    # CLI packages.
    environment = {
      # To get zsh completion for system packages
      pathsToLink = [ "/share/zsh" ];

      systemPackages =
        with pkgs;
        with config.boot.kernelPackages;
        [
          cpupower
          lm_sensors
          lshw
          mesa-demos
          pciutils
          powertop
          psmisc
          usbutils
        ];
    };

    # Enable programs that need special configuration.
    programs = {
      git.enable = true;
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
        enableLsColors = false;
        enableCompletion = false;
        promptInit = "";
        setOptions = lib.mkForce [ ];
      };
    };
  };
}
