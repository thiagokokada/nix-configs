{ config, lib, pkgs, inputs, ... }:

{
  nixpkgs.overlays = [ (import inputs.nubank) ];

  home.packages = pkgs.nubank.desktop-tools;

  # This is a hack to override priorities for those packages in PATH
  home.sessionVariables.PATH = with pkgs.nubank;
    "${lib.makeBinPath ([ dart flutter hover ] ++ all-tools)}:$PATH";
}
