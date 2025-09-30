{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.nixos.games.retroarch;
  finalPackage =
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
    enable = lib.mkEnableOption "RetroArch config";
    cores = lib.mkOption {
      type = with lib.types; either (enum [ "all" ]) (listOf str);
      default = [
        "beetle-lynx"
        "beetle-ngp"
        "beetle-pce-fast"
        "beetle-pcfx"
        "beetle-supergrafx"
        "beetle-wswan"
        "bsnes-hd"
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
        "snes9x"
        "stella"
        "swanstation"
        "yabause"
      ];
      description = "List of cores to include. Pass `all` to use `retroarchFull` instead.";
    };
    finalPackage = lib.mkOption {
      type = lib.types.package;
      description = "Final package.";
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    nixos.games.retroarch.finalPackage = finalPackage;

    environment.systemPackages = [ finalPackage ];

    services.xserver.desktopManager.retroarch = {
      inherit (config.nixos.games.retroarch) package;
      enable = true;
    };
  };
}
