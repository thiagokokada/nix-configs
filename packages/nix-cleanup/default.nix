{ writeShellApplication
, lib
, coreutils
, gawk
, gnugrep
, home-manager
, nix
, substituteAll
, isNixOS ? false
}:

writeShellApplication {
  name =
    if isNixOS
    then "nixos-cleanup"
    else "nix-cleanup";

  text = lib.readFile (substituteAll {
    src = ./nix-cleanup.sh;
    isNixOS = if isNixOS then "1" else "0";
  });

  runtimeInputs = [
    coreutils
    gawk
    gnugrep
    home-manager
    nix
  ];
}
