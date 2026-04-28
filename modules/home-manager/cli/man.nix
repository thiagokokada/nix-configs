{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.cli.man;

  wrappedPackage = pkgs.symlinkJoin {
    name = "${pkgs.mandoc.name}-wrapped";
    paths = [ pkgs.mandoc ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -f "$out/bin/man"
      makeWrapper ${lib.getExe pkgs.mandoc} "$out/bin/man" \
        --run 'if [ -t 1 ]; then cols="$(${lib.getExe' pkgs.ncurses "tput"} cols 2>/dev/null || true)"; if [ -n "$cols" ]; then set -- -O "width=$cols" "$@"; fi; fi'
    '';
  };
in
{
  options.home-manager.cli.man = {
    enable = lib.mkEnableOption "mandoc-based man configuration" // {
      default = config.home-manager.cli.enable;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = wrappedPackage;
      description = "The `mandoc` package to use for manpage lookup and indexing.";
    };

    cache.enable = lib.mkEnableOption "mandoc database generation for Home Manager manpages" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.man = {
      inherit (cfg) package;
      enable = true;
      generateCaches = false;
    };

    home.extraProfileCommands = lib.mkIf cfg.cache.enable ''
      if [ -d "$out/share/man" ]; then
        ${lib.getExe' cfg.package "makewhatis"} -T utf8 "$out/share/man"
      fi
    '';

    xdg.dataFile."mandoc/man".source = config.home.path + "/share/man";

    home.sessionSearchVariables.MANPATH = lib.mkBefore [ "${config.xdg.dataHome}/mandoc/man" ];
  };
}
