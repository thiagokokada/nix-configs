{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.nixos.games.steam;
in
{
  options.nixos.games.steam = {
    enable = lib.mkEnableOption "Steam config" // {
      default = config.nixos.games.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gamescope
      mangohud
    ];

    programs = {
      gamescope = {
        args = [ "--rt" ];
        capSysNice = true;
      };

      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession = {
          enable = true;
          args = [
            "--fsr-sharpness 10"
            "-U"
            "--adaptive-sync"
          ];
        };
      };
    };
  };
}
