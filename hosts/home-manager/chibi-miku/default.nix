{ ... }:

{
  home.stateVersion = "26.05";

  targets.genericLinux.enable = true;

  home-manager = {
    cli = {
      icons.enable = true;
      git.gui.enable = true;
    };
    desktop = {
      fonts.fontconfig.enable = true;
      ghostty.enable = true;
      mpv.enable = true;
      nixgl.enable = false;
    };
    dev = {
      enable = true;
      nix.languageServer = "nil";
    };
  };

  # Remap '+C t ç
  home.file.".XCompose".text = ''
    include "%L"
    <dead_acute> <c> : "ç" U00E7
    <dead_acute> <C> : "Ç" U00C7
  '';
}
