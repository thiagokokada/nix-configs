{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.home-manager.cli.ssh.enable = lib.mkEnableOption "SSH config" // {
    default = config.home-manager.cli.enable;
  };

  config = lib.mkIf config.home-manager.cli.ssh.enable {
    home.packages = with pkgs; [ mosh ];

    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      compression = true;
      forwardAgent = true;
      serverAliveCountMax = 2;
      serverAliveInterval = 300;
      includes = [ "local.d/*" ];
      extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
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
