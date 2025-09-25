prefix:
{
  config,
  lib,
  libEx,
  flake,
  pkgs,
  ...
}:
let
  cfg = config.${prefix}.home;
in
{
  options.${prefix}.home = {
    enable = lib.mkEnableOption "home config" // {
      default = true;
    };
    restoreBackups = lib.mkEnableOption "restore backup files before activation";
    username = lib.mkOption {
      description = "Main username.";
      type = lib.types.str;
      default = "thiagoko";
    };
    extraModules = lib.mkOption {
      description = "Extra modules to import.";
      type = with lib.types; coercedTo attrs (x: [ x ]) (listOf attrs);
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Home-Manager standalone already adds home-manager to PATH, so we
    # are adding here only for NixOS
    environment.systemPackages = with pkgs; [ home-manager ];

    home-manager = rec {
      backupFileExtension = "hm-backup";
      useUserPackages = true;
      useGlobalPkgs = true;
      users.${cfg.username} = {
        inherit (config) meta device theme;
        imports = [ flake.outputs.homeModules.default ] ++ cfg.extraModules;
        home-manager = {
          inherit (config.networking) hostName;
          meta.restoreBackups = lib.mkIf cfg.restoreBackups { inherit backupFileExtension; };
        };
      };
      extraSpecialArgs = { inherit flake libEx; };
    };
  };
}
