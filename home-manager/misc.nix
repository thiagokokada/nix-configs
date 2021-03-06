{ config, lib, pkgs, ... }:

{
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  imports = [ ../overlays ];

  home.packages = with pkgs; [
    coreutils
    curl
    dos2unix
    each
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
    unzip
    wget
    zip
  ];

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  programs.zsh.shellAliases = {
    # TODO: home-manager script is not useful in Flakes yet
    # "hm" = "home-manager";
    "nix-shell-unstable" = "nix-shell -I nixpkgs=channel:nixpkgs-unstable";
  };
}
