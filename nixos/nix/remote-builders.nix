{ config, lib, ... }:

let
  cfg = config.nixos.nix.remote-builders;
in
{
  options.nixos.nix.remote-builders = {
    enable = lib.mkEnableOption "remote-builders config for nixpkgs" // {
      default = config.nixos.desktop.tailscale.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    # Compile via remote builders+Tailscale
    nix = {
      buildMachines = [
        {
          hostName = "100.97.139.21";
          system = "aarch64-linux";
          protocol = "ssh-ng";
          maxJobs = 4;
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUY5a3NRZkFGWTRSbVRmdUEzTDdTQ1Z0YlpsZ2hodVBWSDAxWTRDbytvOHIgcm9vdEB6YXRzdW5lLW5peG9zCg==";
        }
      ];

      distributedBuilds = true;

      settings = {
        builders-use-substitutes = true;
      };
    };
  };
}
