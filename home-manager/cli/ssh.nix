{ config, lib, pkgs, ... }:

{
  options.home-manager.cli.ssh.enable = lib.mkDefaultOption "SSH config" // {
    default = config.home-manager.cli.enable;
  };

  config = lib.mkIf config.home-manager.cli.ssh.enable {
    home.packages = with pkgs; [ mosh ];

    programs.ssh = {
      enable = true;
      compression = true;
      forwardAgent = true;
      serverAliveCountMax = 2;
      serverAliveInterval = 300;
      extraOptionOverrides = {
        Include = "local.d/*";
      };
      extraConfig = ''
        AddKeysToAgent yes
      '' + lib.optionalString pkgs.stdenv.isDarwin ''
        IgnoreUnknown UseKeychain
        UseKeychain yes
      '';
      matchBlocks = {
        "github.com" = {
          identityFile = with config.home; "${homeDirectory}/.ssh/github";
        };
        "git.sr.ht" = {
          identityFile = with config.home; "${homeDirectory}/.ssh/sourcehut";
        };
        "gitlab.com" = {
          identityFile = with config.home; "${homeDirectory}/.ssh/gitlab";
        };
      };
    };
  };
}
