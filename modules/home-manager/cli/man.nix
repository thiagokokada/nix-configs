{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.cli.man;
in
{
  options.home-manager.cli.man = {
    enable = lib.mkEnableOption "mandoc-based man configuration" // {
      default = config.home-manager.cli.enable;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mandoc;
      description = "The `mandoc` package to use for manpage lookup and indexing.";
    };

    cache.enable = lib.mkEnableOption "mandoc database generation for Home Manager manpages" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.man = {
      enable = true;
      package = cfg.package;
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
