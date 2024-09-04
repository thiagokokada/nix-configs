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
    nix.linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
  };
}
