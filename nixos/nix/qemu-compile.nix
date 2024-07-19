{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.nix.qemu-compile;
in
{
  options.nixos.nix.qemu-compile.enable = lib.mkEnableOption "compile other archs via QEMU";

  config = lib.mkIf cfg.enable {
    # Allow compilation of packages for other architectures (e.g.: ARM64) via
    # QEMU e.g. nix-build -A <pkg> --argstr system aarch64-linux
    # https://nixos.wiki/wiki/NixOS_on_ARM#Compiling_through_QEMU
    boot.binfmt.emulatedSystems =
      {
        "x86_64-linux" = [ "aarch64-linux" ];
        "aarch64-linux" = [ "x86_64-linux" ];
      }
      .${pkgs.system} or [ ];
  };
}
