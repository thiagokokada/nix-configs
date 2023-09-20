{ lib, config, ... }:

let
  inherit (config.meta) username;
  cfg = config.nixos.games.corectrl;
in
{
  options.nixos.games.corectrl.enable = lib.mkEnableOption "corectrl config" // {
    default = config.nixos.games.enable && (config.nixos.games.gpu == "amd");
  };

  config = lib.mkIf cfg.enable {
    programs.corectrl = {
      enable = true;
      gpuOverclock.enable = true;
    };

    # Added user to groups
    users.users.${username}.extraGroups = [ "corectrl" ];
  };
}
