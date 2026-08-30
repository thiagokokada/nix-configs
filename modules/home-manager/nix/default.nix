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

    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = flake.outputs.internal.configs.nix;
    };

    # Config for ad-hoc nix commands invocation
    xdg.configFile."nixpkgs/config.nix".text =
      lib.generators.toPretty { }
        flake.outputs.internal.configs.nixpkgs;
  };
}
