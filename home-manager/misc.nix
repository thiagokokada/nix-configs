{ config, lib, pkgs, ... }:

{
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  imports = [ ../overlays ];

  home.packages = with pkgs; [
    coreutils
    curl
    dos2unix
    jq
    moreutils
    nox
    p7zip
    page
    pv
    python3Packages.youtube-dl
    ripgrep
    stow
    tealdeer
    tig
    unrar
    unstable.each
    unzip
    wget
    zip
  ];

  programs.zsh.shellAliases = {
    "hm" = "home-manager";
  };
}
