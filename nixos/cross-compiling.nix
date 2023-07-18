{ config, lib, ... }:

{
  options.nixos.cross-compiling = {
    enable = lib.mkDefaultOption "cross-compiling config for nixpkgs";
    emulatedSystems = lib.mkOption {
      description = "List of systems to emulate";
      type = lib.types.listOf lib.types.str;
      default = [ "aarch64-linux" ];
    };
  };
  config = lib.mkIf config.nixos.cross-compiling.enable {
    # Allow compilation of packages ARM/ARM64 architectures via QEMU
    # e.g. nix-build -A <pkg> --argstr system aarch64-linux
    # https://nixos.wiki/wiki/NixOS_on_ARM#Compiling_through_QEMU
    boot.binfmt = {
      inherit (config.nixos.cross-compiling) emulatedSystems;
    };
  };
}
