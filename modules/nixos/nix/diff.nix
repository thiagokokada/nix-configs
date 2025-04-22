{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.nix.diff;
in
{
  options.nixos.nix.diff.enable = lib.mkEnableOption "diff configuration on activation" // {
    default = config.nixos.nix.enable;
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.diff =
      # bash
      ''
        export PATH="${lib.makeBinPath [ config.nix.package ]}:$PATH"
        if [[ -e '/run/current-system' ]]; then
          echo "showing changes compared to /run/current-system..."
          ${lib.getExe pkgs.nvd} diff '/run/current-system' "$systemConfig" || true
        fi
      '';
  };
}
