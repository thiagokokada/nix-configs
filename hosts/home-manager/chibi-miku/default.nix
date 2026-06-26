{ lib, ... }:

{
  home.stateVersion = "26.05";

  targets.genericLinux.enable = true;

  home-manager = {
    cli = {
      git.gui.enable = true;
      gnu.enable = true;
      icons.enable = true;
    };
    desktop = {
      enable = true;
      chromium.enable = false;
      firefox.enable = false;
      kitty.fontSize = 11.0;
      mpv = {
        profile = [ "fast" ];
        vapoursynth.enable = false;
      };
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

  programs.mpv.config = {
    hwdec = "v4l2m2m-copy";
    vo = "gpu";
  };
}
