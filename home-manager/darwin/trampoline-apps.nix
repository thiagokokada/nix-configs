{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.darwin.trampoline;
in
{
  # https://github.com/rycee/home-manager/issues/1341
  options.home-manager.darwin.trampoline.enable = lib.mkEnableOption "trampoline macOS apps" // {
    default = config.home-manager.darwin.enable;
  };

  config = lib.mkIf cfg.enable {
    # Install MacOS applications to the user Applications folder. Also update Docked applications
    home.extraActivationPath = with pkgs; [
      dockutil
      gawk
      rsync
    ];

    home.activation.trampolineApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      . ${./trampoline-apps.sh}
      fromDir="$HOME/Applications/Home Manager Apps"
      toDir="$HOME/Applications/Home Manager Trampolines"
      run sync_trampolines "$fromDir" "$toDir"
    '';
  };
}
