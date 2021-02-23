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

  xdg.userDirs.enable = true;

  home.activation.xdg-user-dirs-update = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -z "''${DRY_RUN:-}" ]; then
      XDG_CONFIG_HOME=$(${pkgs.coreutils}/bin/mktemp -d) \
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update
    fi
  '';

  programs.zsh.shellAliases = {
    # TODO: home-manager script is not useful in Flakes yet
    # "hm" = "home-manager";
    "nix-shell-unstable" = "nix-shell -I nixpkgs=channel:nixpkgs-unstable";
  };
}
