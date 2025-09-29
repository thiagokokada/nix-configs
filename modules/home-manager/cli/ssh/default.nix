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

    programs = {
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        package = with pkgs; lib.mkIf stdenv.isLinux openssh;

        includes = [ "local.d/*" ];

        # We want to use the macOS keychain if available
        extraConfig = lib.optionalString config.home-manager.darwin.enable ''
          IgnoreUnknown UseKeychain
          UseKeychain yes
        '';

        matchBlocks = {
          "*" = {
            addKeysToAgent = "yes";
            compression = true;
            forwardAgent = true;
            serverAliveCountMax = 2;
            serverAliveInterval = 300;
          };
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

      zsh.initContent =
        # Checks if SSH_AUTH_SOCK is set and the socket is working, or start a
        # new ssh-agent otherwise (works in any OS)
        # bash
        ''
          source ${./ssh-agent.zsh}
        '';
    };

    # Start SSH agent via systemd (Linux-only)
    # Since this is a systemd user service, it stays between sessions
    services.ssh-agent.enable = lib.mkIf pkgs.stdenv.isLinux true;
  };
}
