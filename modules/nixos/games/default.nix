{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.nixos.home) username;
  cfg = config.nixos.games;
in
{
  imports = [
    ./jovian.nix
    ./osu.nix
    ./ratbag.nix
    ./retroarch.nix
    ./steam.nix
  ];

  options.nixos.games = {
    enable = lib.mkEnableOption "games config" // {
      default = config.device.type == "steam-machine";
    };
  };

  config = lib.mkIf cfg.enable {
    # https://fedoraproject.org/wiki/Changes/IncreaseVmMaxMapCount
    # https://pagure.io/fesco/issue/2993#comment-859763
    boot.kernel.sysctl."vm.max_map_count" = 1048576;

    environment.systemPackages = with pkgs; [
      goverlay
      mangohud
      (bottles.override {
        removeWarningPopup = true;
      })
    ];

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 10;
        };
        custom = {
          start = "${lib.getExe pkgs.libnotify} 'GameMode started'";
          end = "${lib.getExe pkgs.libnotify} 'GameMode ended'";
        };
      };
    };

    users.users.${username}.extraGroups = [ "gamemode" ];

    hardware = {
      graphics.enable32Bit = true;
      # Alternative driver for Xbox One/Series S/Series X controllers
      xone.enable = true;
    };
  };
}
