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
        home-manager = { inherit (config.networking) hostName; };
      };
      extraSpecialArgs = {
        inherit flake libEx;
      };
    };

    users.users.${username}.home = lib.mkDefault "/Users/${username}";
  };
}
