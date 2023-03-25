{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium.override {
      enableWideVine = true;
    };
  };
}
