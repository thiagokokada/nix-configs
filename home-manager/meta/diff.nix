{ config, lib, ... }:

let
  cfg = config.home-manager.meta.diff;
in
{
  options.home-manager.meta.diff.enable = lib.mkEnableOption "diff configuration on activation" // {
    default = config.home-manager.meta.enable;
  };

  config = lib.mkIf cfg.enable {
    home.activation.diff = lib.hm.dag.entryAnywhere ''
      if [[ -n ''${oldGenPath:-} ]] && [[ -n ''${newGenPath:-} ]]; then
        ${lib.getExe config.nix.package} \
          --extra-experimental-features 'nix-command' \
          store diff-closures $oldGenPath $newGenPath
      fi
    '';
  };
}

