{ config, lib, ... }:

let
  cfg = config.nix-darwin.system;
in
{
  options.nix-darwin.system.enable = lib.mkEnableOption "system config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment = {
      # https://github.com/nix-darwin/nix-darwin/issues/1507
      etc."zshenv".text =
        lib.mkBefore
          # bash
          ''
            export USER="$(whoami)"
          '';
      # To get zsh completion for system packages
      pathsToLink = [ "/share/zsh" ];
    };

    # Enable sudo via TouchID
    security.pam.services.sudo_local.touchIdAuth = true;

    # Make `system.keyboard.enableKeyMapping` automatically re-apply on boot
    # Needs to also give `/usr/bin/hidutil` permission for "Input Monitoring"
    # https://github.com/nix-darwin/nix-darwin/issues/905#issuecomment-3691729456
    launchd.user.agents.keyboard-remap.serviceConfig =
      lib.mkIf config.system.keyboard.enableKeyMapping
        {
          ProgramArguments = [
            "/usr/bin/hidutil"
            "property"
            "--set"
            ''{"UserKeyMapping":${builtins.toJSON config.system.keyboard.userKeyMapping}}''
          ];
          RunAtLoad = true;
        };
  };
}
