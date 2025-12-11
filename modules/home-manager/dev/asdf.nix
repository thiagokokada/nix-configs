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
          export PATH="''${ASDF_DATA_DIR:-''$HOME/.asdf}/shims:$PATH"
          fpath+=(${pkgs.asdf-vm}/share/zsh/site-functions)
        '';
    };
  };
}
