{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.home-manager.dev.asdf.enable = lib.mkEnableOption "asdf config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.asdf.enable {
    home = {
      file.".asdfrc".text = lib.generators.toKeyValue { } {
        legacy_version_file = "yes";
      };

      packages = with pkgs; [ asdf-vm ];
    };

    programs.zsh = {
      initExtra = ''
        export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
        fpath+=(${pkgs.asdf-vm}/share/zsh/site-functions)
        source "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
      '';
    };
  };
}
