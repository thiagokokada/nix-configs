{ config, lib, pkgs, inputs, ... }:

{
  nixpkgs.overlays = [ (import inputs.nubank) ];

  home.packages = with pkgs.unstable; [ slack ];

  # This is a hack to override priorities for those packages in PATH
  home.sessionVariables.PATH = with pkgs.nubank;
    "${lib.makeBinPath ([ dart flutter hover ] ++ all-tools)}:$PATH";

  xsession.windowManager.i3.extraConfig = ''
    for_window [title="^nubank$"] floating enable
  '';
}
