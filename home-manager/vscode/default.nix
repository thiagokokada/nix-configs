{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = false;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      # Clojure
      betterthantomorrow.calva

      # Go
      golang.go

      # Python
      ms-python.python
      ms-python.vscode-pylance

      # Nix
      b4dm4n.vscode-nixpkgs-fmt
      bbenoist.nix

      # VSpaceCode
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
      {
        name = "rainbow-brackets";
        publisher = "2gua";
        version = "0.0.6";
        sha256 = "sha256-TVBvF/5KQVvWX1uHwZDlmvwGjOO5/lXbgVzB26U8rNQ=";
      }
    ];
    userSettings = with builtins; fromJSON (readFile ./settings.json);
    keybindings = with builtins; fromJSON (readFile ./keybindings.json);
  };
}
