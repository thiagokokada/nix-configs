{ pkgs, ... }:

{
  # Subpixel hinting mode can be chosen by setting the right TrueType interpreter
  # version. The available settings are:
  #
  #     truetype:interpreter-version=35  # Classic mode (default in 2.6)
  #     truetype:interpreter-version=38  # Infinality mode
  #     truetype:interpreter-version=40  # Minimal mode (default in 2.7)
  #
  # There are more properties that can be set, separated by whitespace. Please
  # refer to the FreeType documentation for details.
  environment.sessionVariables.FREETYPE_PROPERTIES = "truetype:interpreter-version=38";

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;

    fonts = with pkgs; [
      corefonts # corefonts works well with Infinality mode, remove otherwise
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Noto Sans Mono" ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
