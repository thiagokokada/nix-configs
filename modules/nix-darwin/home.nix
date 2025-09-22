{
  config,
  lib,
  libEx,
  flake,
  pkgs,
  ...
}:

let
  cfg = config.nix-darwin.home;
  inherit (config.meta) username;
in
{
  imports = [ flake.inputs.home-manager.darwinModules.home-manager ];

  options.nix-darwin.home = {
    enable = lib.mkEnableOption "home config" // {
      default = true;
    };
    extraModules = lib.mkOption {
      description = "Extra modules to import.";
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Home-Manager standalone already adds home-manager to PATH, so we
    # are adding here only for nix-darwin
    environment.systemPackages = with pkgs; [ home-manager ];

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      users.${username} = {
        inherit (config) meta device theme;
        imports = [ ../home-manager ] ++ cfg.extraModules;
        home-manager = {
          inherit (config.networking) hostName;
          # Disable copying applications to ~/Applications
          darwin.copyApps.enable = false;
        };
        # Disable linking applications to ~/Applications
        targets.darwin.linkApps.enable = false;
      };
      extraSpecialArgs = {
        inherit flake libEx;
      };
    };

    # Copy graphical applications to /Applications using nix-darwin
    # https://github.com/nix-community/home-manager/issues/1341#issuecomment-3256894180
    system.build.applications = lib.mkForce (
      pkgs.buildEnv {
        name = "system-applications";
        pathsToLink = "/Applications";
        paths =
          config.environment.systemPackages
          ++ (lib.concatMap (x: x.home.packages) (lib.attrsets.attrValues config.home-manager.users));
      }
    );

    users.users.${username}.home = lib.mkDefault "/Users/${username}";
  };
}
