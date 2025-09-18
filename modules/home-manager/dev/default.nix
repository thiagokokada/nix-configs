{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./asdf.nix
    ./clojure.nix
    ./go.nix
    ./lua.nix
    ./nix.nix
    ./node.nix
    ./python.nix
  ];

  options.home-manager.dev.enable = lib.mkEnableOption "dev config" // {
    default = true;
  };

  config = lib.mkIf config.home-manager.dev.enable {
    home.packages = with pkgs; [
      bash-language-server
      expect
      marksman
      shellcheck
    ];

    programs = {
      direnv.enable = true;
      tealdeer = {
        enable = true;
        settings = {
          display = {
            compact = false;
            use_pager = true;
          };
          updates = {
            auto_update = false;
          };
        };
      };
    };
  };
}
