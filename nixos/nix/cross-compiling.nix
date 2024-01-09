{ config, lib, ... }:

let
  cfg = config.nixos.nix.cross-compiling;
in
{
  options.nixos.nix.cross-compiling = {
    enable = lib.mkEnableOption "cross-compiling config for nixpkgs";
    emulatedSystems = lib.mkOption {
      description = "List of systems to emulate via QEMU";
      type = lib.types.listOf lib.types.str;
      default = [ "aarch64-linux" ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Allow compilation of packages ARM/ARM64 architectures via QEMU
    # e.g. nix-build -A <pkg> --argstr system aarch64-linux
    # https://nixos.wiki/wiki/NixOS_on_ARM#Compiling_through_QEMU
    boot.binfmt = {
      inherit (cfg) emulatedSystems;
    };
  };
}
