{ config, lib, pkgs, self, ... }:

{
  imports = [
    ./desktop.nix
    ./dev.nix
    ./fonts.nix
    ./home.nix
    ./minimal.nix
    ./non-nix.nix
    ./wayland.nix
    ./xserver.nix
    self.inputs.envfs.nixosModules.envfs
  ];
}
