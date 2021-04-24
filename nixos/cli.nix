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
    netcat-gnu
    openssl
    p7zip
    pciutils
    powertop
    psmisc
    rlwrap
    telnet
    tmux
    unrar
    unzip
    usbutils
    wget
    zip
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
