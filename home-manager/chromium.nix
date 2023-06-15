{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
      # Needed for Wayland
      commandLineArgs = "--ozone-platform-hint=auto";
    };
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # vimium-c
    ];
  };
}
