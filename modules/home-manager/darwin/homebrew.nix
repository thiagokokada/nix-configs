{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.darwin.homebrew;
in
{
  options.home-manager.darwin.homebrew = {
    enable = lib.mkEnableOption "Homebrew config";
    prefix = lib.mkOption {
      type = lib.types.path;
      description = "Homebrew's prefix";
      default = if pkgs.stdenv.hostPlatform.isAarch64 then "/opt/homebrew" else "/usr/local";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      initExtraBeforeCompInit =
        lib.mkBefore # bash
          ''
            if [[ -f "${cfg.prefix}/bin/brew" ]]; then
              export HOMEBREW_NO_ENV_HINTS=1
              export HOMEBREW_NO_ANALYTICS=1
              export HOMEBREW_PREFIX="${cfg.prefix}"
              export HOMEBREW_CELLAR="${cfg.prefix}/Cellar"
              export HOMEBREW_REPOSITORY="${cfg.prefix}"
              fpath+=("${cfg.prefix}/share/zsh/site-functions")
              export PATH="${cfg.prefix}/bin:${cfg.prefix}/sbin:$PATH"
            fi
          '';
    };
  };
}
