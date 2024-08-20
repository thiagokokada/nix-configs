{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.home-manager.dev.python.enable = lib.mkEnableOption "Python config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.python.enable {
    home.packages = with pkgs; [
      pyright
      python3
      ruff
      uv
    ];
  };
}
