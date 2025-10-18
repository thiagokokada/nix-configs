{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.home-manager.dev.asdf.enable = lib.mkEnableOption "asdf config";

  config = lib.mkIf config.home-manager.dev.asdf.enable {
    home = {
      activation.reshimAsdf =
        lib.hm.dag.entryAfter [ "writeBoundary" ]
          # bash
          ''
            run ${lib.getExe pkgs.asdf-vm} reshim
          '';

      file.".asdfrc".text = lib.generators.toKeyValue { } {
        legacy_version_file = "yes";
      };

      packages = with pkgs; [ asdf-vm ];
    };

    programs.zsh = {
      initContent =
        # bash
        ''
          export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
          fpath+=(${pkgs.asdf-vm}/share/zsh/site-functions)
          source "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
        '';
    };
  };
}
