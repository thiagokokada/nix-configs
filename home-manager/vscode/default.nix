{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    extensions = with pkgs.unstable.vscode-extensions; [
      # Nix
      b4dm4n.vscode-nixpkgs-fmt
      bbenoist.nix

      # VSpaceCode related
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
    userSettings = with builtins; fromJSON (readFile ./settings.json);
    keybindings = with builtins; fromJSON (readFile ./keybindings.json);
  };
}
