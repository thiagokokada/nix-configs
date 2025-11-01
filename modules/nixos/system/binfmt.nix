{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.system.binfmt;
in
{
  options.nixos.system.binfmt = {
    enable = lib.mkEnableOption "binfmt configuration";
    windows.enable = lib.mkEnableOption "Windows emulation (via WINE)";
  };

  config = lib.mkIf cfg.enable {
    # Allow compilation of packages for other architectures (e.g.: ARM64) via
    # QEMU e.g. nix-build -A <pkg> --argstr system aarch64-linux
    # https://nixos.wiki/wiki/NixOS_on_ARM#Compiling_through_QEMU
    boot.binfmt.emulatedSystems =
      (
        {
          "x86_64-linux" = [ "aarch64-linux" ];
          "aarch64-linux" = [ "x86_64-linux" ];
        }
        .${pkgs.stdenv.hostPlatform.system} or [ ]
      )
      ++ lib.optionals cfg.windows.enable [
        "x86_64-windows"
      ];
  };
}
