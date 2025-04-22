{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.meta.diff;
in
{
  options.home-manager.meta.diff.enable = lib.mkEnableOption "diff configuration on activation" // {
    default = config.home-manager.meta.enable;
  };

  config = lib.mkIf cfg.enable {
    home.activation.diff =
      lib.hm.dag.entryAnywhere
        # bash
        ''
          export PATH="${lib.makeBinPath [ config.nix.package ]}:$PATH"
          if [[ -n "''${oldGenPath:-}" ]] && [[ -n "''${newGenPath:-}" ]]; then
            ${lib.getExe pkgs.nvd} diff "$oldGenPath" "$newGenPath" || true
          fi
        '';
  };
}
