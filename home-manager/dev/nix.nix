{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.home-manager.dev.nix.enable = lib.mkEnableOption "Nix config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.nix.enable {
    home.packages = with pkgs; [
      nix-update
      nixd
      nixfmt-rfc-style
      nurl
      statix
    ];
  };
}
