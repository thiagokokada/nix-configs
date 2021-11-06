{ pkgs, self, ... }:

{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix = import ../shared/nix.nix { inherit pkgs self; };
}
