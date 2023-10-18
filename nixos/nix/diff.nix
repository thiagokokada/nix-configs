{ config, lib, ... }:

let
  cfg = config.nixos.nix.diff;
in
{
  options.nixos.nix.diff.enable = lib.mkEnableOption "diff configuration on activation" // {
    default = config.nixos.nix.enable;
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.diff = ''
      if [[ -e /run/current-system ]]; then
        echo "showing changes compared to /run/current-system..."
        ${lib.getExe config.nix.package} \
          --extra-experimental-features 'nix-command' \
          store diff-closures /run/current-system "$systemConfig" || true
      fi
    '';
  };
}
