{ config, lib, pkgs, ... }:

{
  # Allow compilation of packages ARM/ARM64 architectures via QEMU
  # e.g. nix-build -A <pkg> --argstr system aarch64-linux
  # https://nixos.wiki/wiki/NixOS_on_ARM#Compiling_through_QEMU
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.extraOptions = ''
    extra-platforms = aarch64-linux arm-linux
  '';
}
