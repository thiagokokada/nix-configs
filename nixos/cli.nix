{ config, pkgs, ... }:

{
  # CLI packages.
  environment = {
    # To get zsh completion for system packages
    pathsToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      bc
      bind
      curl
      dos2unix
      ffmpeg
      file
      glxinfo
      htop
      linuxPackages.cpupower
      lm_sensors
      lshw
      lsof
      mediainfo
      multitime
      netcat-gnu
      openssl
      pciutils
      powertop
      psmisc
      python3
      rlwrap
      telnet
      tmux
      unrar
      unzip
      usbutils
      wget
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
    };
    zsh = {
      enable = true;
      promptInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
      '';
    };
  };
}
