{ config, lib, pkgs, ... }:

let
  nix-where-is = pkgs.writeShellScriptBin "nix-where-is" ''
    set -euo pipefail

    readonly program_name="''${1:-}"

    if [[ -z "''${program_name}" ]]; then
      echo "usage: $(basename ''${0}) PROGRAM"
      exit 1
    fi

    readonly symbolic_link="$(which "''${program_name}")"
    readlink -f "''${symbolic_link}"
  '';
in
{
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  imports = [ ../overlays ];

  home.packages = with pkgs; [
    coreutils
    curl
    dos2unix
    each
    jo
    jq
    moreutils
    nix-where-is
    nox
    p7zip
    page
    pv
    python3Packages.youtube-dl
    ripgrep
    stow
    tealdeer
    tig
    unar
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
