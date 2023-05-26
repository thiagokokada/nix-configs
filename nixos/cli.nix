{ pkgs, ... }:

{
  # CLI packages.
  environment = {
    # To get zsh completion for system packages
    pathsToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      glxinfo
      linuxPackages.cpupower
      lm_sensors
      lshw
      pciutils
      powertop
      psmisc
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
}
