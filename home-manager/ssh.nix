{ config, lib, pkgs, ... }:

{
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

  home.packages = with pkgs; [ mosh ];

  # `flutter pub get` fails with "Bad owner or permissions on $HOME/.ssh/config"
  # I don't know why
  home.file.".ssh/config" = {
    force = true;
  };

  home.activation.copy-ssh-file = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    file="$(readlink $HOME/.ssh/config)"
    $DRY_RUN_CMD rm $VERBOSE_ARG -f "$HOME/.ssh/config"
    $DRY_RUN_CMD cp $VERBOSE_ARG "$file" "$HOME/.ssh/config"
    $DRY_RUN_CMD chmod 600 "$HOME/.ssh/config"
  '';
}
