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

    # Compile via remote builders+Tailscale
    nix = lib.mkIf config.nixos.desktop.tailscale.enable {
      buildMachines = [{
        hostName = "zatsune-nixos-uk";
        system = "aarch64-linux";
        protocol = "ssh-ng";
        speedFactor = 4;
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUY5a3NRZkFGWTRSbVRmdUEzTDdTQ1Z0YlpsZ2hodVBWSDAxWTRDbytvOHIgcm9vdEB6YXRzdW5lLW5peG9zCg==";
      }];

      distributedBuilds = true;

      settings = {
        builders-use-substitutes = true;
      };
    };
  };
}
