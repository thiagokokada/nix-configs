{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
      # Needed for Wayland
      commandLineArgs = "--ozone-platform-hint=auto";
    };
  };
}
