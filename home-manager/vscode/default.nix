{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    extensions = with pkgs.unstable.vscode-extensions; [
      b4dm4n.vscode-nixpkgs-fmt
      bbenoist.nix

      # VSpaceCode related
      # TODO: fix it since it is broken in edit mode
      bodil.file-browser
      kahole.magit
      vscodevim.vim
      vspacecode.vspacecode
      vspacecode.whichkey
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "fuzzy-search";
        publisher = "jacobdufault";
        version = "0.0.3";
        sha256 = "sha256-oN1SzXypjpKOTUzPbLCTC+H3I/40LMVdjbW3T5gib0M=";
      }
    ];
    userSettings = {
      "update.channel" = "none";
      "telemetry.telemetryLevel" = "off";
      "keyboard.dispatch" = "keyCode";
    };
    keybindings = with builtins; fromJSON (readFile ./keybindings.json);
  };
}
