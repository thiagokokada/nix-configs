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
  inherit (config.mainUser) username;
in
{
  imports = [ flake.inputs.home-manager.darwinModules.home-manager ];

  options.nix-darwin.home = {
    enable = lib.mkEnableOption "home config" // {
      default = true;
    };
    imports = lib.mkOption {
      description = "Modules to import.";
      type = lib.types.listOf lib.types.path;
      default = [ ../home-manager ];
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
        inherit (config.nix-darwin.home) imports;
        home.stateVersion = lib.mkDefault "24.05";
      };
      extraSpecialArgs = {
        inherit flake libEx;
      };
    };

    users.users.${username}.home = lib.mkDefault "/Users/${username}";
  };
}
