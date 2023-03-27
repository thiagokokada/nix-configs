{ nix-output-monitor
, writeShellApplication
}:

writeShellApplication {
  name = "nom-rebuild";
  # Not including sudo/nixos-rebuild since they are included in NixOS base
  runtimeInputs = [ nix-output-monitor ];
  text = ''
    nixos-rebuild "$@" |& nom
  '';
}
