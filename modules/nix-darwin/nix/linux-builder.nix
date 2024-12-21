{
  config,
  lib,
  ...
}:

let
  cfg = config.nix-darwin.nix.linux-builder;
in
{
  options.nix-darwin.nix.linux-builder.enable = lib.mkEnableOption "Linux builder config" // {
    default = config.nix-darwin.nix.enable;
  };

  config = lib.mkIf cfg.enable {
    launchd.daemons.linux-builder = {
      serviceConfig = {
        StandardOutPath = "/var/log/darwin-builder.log";
        StandardErrorPath = "/var/log/darwin-builder.log";
      };
    };

    nix.linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      config = {
        # https://github.com/LnL7/nix-darwin/issues/913
        services.openssh.enable = true;
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
    };
  };
}
