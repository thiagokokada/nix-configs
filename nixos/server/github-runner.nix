{ config, lib, ... }:

let
  cfg = config.nixos.server.github-runner;
in
{
  options.nixos.server.github-runner.enable = lib.mkEnableOption "github-runner for this repo config";

  config = lib.mkIf cfg.enable {
    services.github-runners."nix-configs" = {
      enable = true;
      extraLabels = [ "nixos" ];
      tokenFile = "/etc/github-runner/nix-configs.token";
      url = "https://github.com/thiagokokada/nix-configs";
    };
  };
}
