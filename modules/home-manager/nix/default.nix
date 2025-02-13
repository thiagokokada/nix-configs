{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  cfg = config.home-manager.nix;
in
{
  options.home-manager.nix.enable = lib.mkEnableOption "Nix config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home = {
      # Add some Nix related packages
      packages = with pkgs; [
        nix-cleanup
        nix-whereis
      ];
      # For standalone HM usage to make e.g.: nix-shell work as expected
      sessionVariables.NIX_PATH = "nixpkgs=${flake.inputs.nixpkgs}";
    };

    # To make cachix work you need add the current user as a trusted-user on Nix
    # sudo echo "trusted-users = $(whoami)" >> /etc/nix/nix.conf
    # Another option is to add a group by prefixing it by @, e.g.:
    # sudo echo "trusted-users = @wheel" >> /etc/nix/nix.conf
    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = lib.mkMerge [
        (import ../../shared/config/nix-conf.nix)
        (import ../../shared/config/substituters.nix)
      ];
    };

    # Config for ad-hoc nix commands invocation
    nixpkgs.config = import ./nixpkgs-config.nix;
    xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
  };
}
