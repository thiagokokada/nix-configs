{ config, lib, pkgs, flake, ... }:

let
  inherit (flake) inputs;
  cfg = config.home-manager.cli.nnn;
in
{
  options.home-manager.cli.nnn = {
    enable = lib.mkEnableOption "nnn config" // {
      default = config.home-manager.cli.enable;
    };
    # Do not forget to set 'Hack Nerd Mono Font' as the terminal font
    enableIcons = lib.mkEnableOption "icons" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals cfg.enableIcons [
      config.home-manager.desktop.theme.fonts.symbols.package
    ];

    programs.nnn = {
      enable = true;
      package = pkgs.nnn.override { withNerdIcons = cfg.enableIcons; };
      bookmarks = {
        d = "~/Documents";
        D = "~/Downloads";
        p = "~/Pictures";
        v = "~/Videos";
        m = "/mnt";
        "/" = "/";
      };
      extraPackages = with pkgs; [
        bat
        eza
        fzf
        mediainfo
      ] ++ lib.optionals (!stdenv.isDarwin) [
        ffmpegthumbnailer
        sxiv
      ];
      plugins = {
        src = "${inputs.nnn-plugins}/plugins";
        mappings = {
          c = "fzcd";
          f = "finder";
          o = "fzopen";
          p = "preview-tui";
          t = "nmount";
          v = "imgview";
        };
      };
    };

    programs.zsh.initExtra = lib.optionalString config.programs.zsh.enable /* bash */ ''
      # Export NNN_TMPFILE to quit on cd always
      export NNN_TMPFILE="${config.xdg.configHome}/nnn/.lastd"
      . ${config.programs.nnn.finalPackage}/share/quitcd/quitcd.bash_sh_zsh
    '';
  };
}
