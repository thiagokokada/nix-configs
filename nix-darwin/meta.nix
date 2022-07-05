{ pkgs, flake, ... }:

{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # nix.settings is missing on nix-darwin
  # https://github.com/LnL7/nix-darwin/issues/433
  # nix = import ../shared/nix.nix { inherit pkgs flake; };
}
