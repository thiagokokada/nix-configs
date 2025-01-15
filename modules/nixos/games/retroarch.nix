{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.nixos.games.retroarch;
  finalPkg =
    if (cfg.cores == "all") then
      pkgs.retroarch-full
    else
      pkgs.retroarch.withCores (
        cores:
        lib.pipe cores [
          (lib.getAttrs cfg.cores)
          lib.attrValues
        ]
      );
in
{
  options.nixos.games.retroarch = {
    enable = lib.mkEnableOption "RetroArch config" // {
      default = config.nixos.games.enable;
    };
    cores = lib.mkOption {
      type = with lib.types; either (enum [ "all" ]) (listOf str);
      default = [
        "atari800"
        "beetle-lynx"
        "beetle-ngp"
        "beetle-pce-fast"
        "beetle-pcfx"
        "beetle-supergrafx"
        "beetle-wswan"
        "blastem"
        "bsnes-hd"
        "desmume"
        "fbneo"
        "flycast"
        "gambatte"
        "genesis-plus-gx"
        "melonds"
        "mgba"
        "mupen64plus"
        "neocd"
        "nestopia"
        "pcsx2"
        "ppsspp"
        "prosystem"
        "snes9x"
        "stella"
        "swanstation"
        "yabause"
      ];
      description = "List of cores to include. Pass `all` to use `retroarchFull` instead.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      description = "Final package.";
      internal = true;
    };
  };

  config = lib.mkIf cfg.enable {
    nixos.games.retroarch.package = finalPkg;

    environment.systemPackages = [ finalPkg ];

    services.xserver.desktopManager.retroarch = {
      enable = true;
      package = finalPkg;
    };
  };
}
