{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.system.nix-ld;
in
{
  options.nixos.system.nix-ld = {
    enable = lib.mkEnableOption "nix-ld config" // {
      default = builtins.any (x: config.device.type == x) [
        "desktop"
        "laptop"
        "steam-machine"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        (runCommand "steamrun-lib" { } "mkdir $out; ln -s ${steam-run.fhsenv}/usr/lib64 $out/lib")
      ];
    };
  };
}
