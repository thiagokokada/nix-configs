{ config, lib, ... }:

let
  cfg = config.nixos.nix.remote-builders;
in
{
  options.nixos.nix.remote-builders.enable =
    lib.mkEnableOption "remote-builders config for nixpkgs"
    // {
      default = config.nixos.desktop.tailscale.enable;
    };

  config = lib.mkIf cfg.enable {
    # Compile via remote builders+Tailscale
    nix = {
      buildMachines = [
        {
          hostName = "zatsune-nixos-br.quokka-char.ts.net";
          system = "aarch64-linux";
          protocol = "ssh-ng";
          maxJobs = 4;
          # base64 -w0 /etc/ssh/ssh_host_<type>_key.pub
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUZEbENUZlZyQUlIVFI0T1RSMENtL2FUdUhOQmdEcE5RMFBncDEvaWFQaFAgcm9vdEB6YXRzdW5lLW5peG9zCg==";
          supportedFeatures = [
            "nixos-test"
            "benchmark"
            "big-parallel"
            "kvm"
          ];
        }
      ];

      distributedBuilds = true;

      settings = {
        builders-use-substitutes = true;
      };
    };
  };
}
