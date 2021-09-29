{ config, pkgs, ... }:

{
  # CLI packages.
  environment.systemPackages = with pkgs; [
    aria2
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
    rlwrap
    telnet
    tmux
    unar
    usbutils
    wget
  ];

  # Enable programs that need special configuration.
  programs = {
    iftop.enable = true;
    mtr.enable = true;
    zsh = {
      enable = true;
      promptInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
      '';
    };
  };
}
