{ config, lib, ... }:

let
  cfg = config.nix-darwin.homebrew;
  inherit (config.meta) username;
in
{
  options.nix-darwin.homebrew = {
    enable = lib.mkEnableOption "Homebrew config" // {
      default = true;
    };
    prefix = lib.mkOption {
      type = lib.types.path;
      description = "Homebrew's prefix";
      default = "/opt/homebrew/bin";
    };
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [
        "betterdisplay"
        "domzilla-caffeine"
        "firefox"
        "google-chrome"
        "iterm2"
        "linearmouse"
        "rectangle"
        "stats"
      ];
    };

    home-manager.users.${username}.config.programs.zsh = {
      initExtraBeforeCompInit =
        lib.mkBefore # bash
          ''
            if [[ -f "${cfg.prefix}/brew" ]]; then
              export HOMEBREW_NO_ENV_HINTS=1
              export HOMEBREW_NO_ANALYTICS=1
              eval "$(/opt/homebrew/bin/brew shellenv)"
              fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
            fi
          '';
    };
  };
}
