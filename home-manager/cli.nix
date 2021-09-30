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
  home.packages = with pkgs; [
    aria2
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
    rar
    ripgrep
    stow
    tealdeer
    tig
    unzip
    wget
    zip
  ];
}
