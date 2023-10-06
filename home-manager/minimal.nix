{ config, lib, ... }:

{
  imports = [ ./default.nix ];

  home = {
    # Not sure why this variable is not filling up automatically
    sessionPath = [ "${config.home.homeDirectory}/.nix-profile/bin" ];
    stateVersion = "23.11";
  };

  # Disable some modules
  home-manager = {
    darwin.enable = false;
    dev.nix.enable = true;
    cli = {
      enable = false;
      git.enable = true;
      htop.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
    editor = {
      neovim.enableLsp = true;
      helix.enable = false;
    };
    meta.enable = false;
  };

  # Disable systemd services/sockets/timers/etc.
  systemd.user = {
    automounts = lib.mkForce { };
    mounts = lib.mkForce { };
    paths = lib.mkForce { };
    services = lib.mkForce { };
    sessionVariables = lib.mkForce { };
    slices = lib.mkForce { };
    sockets = lib.mkForce { };
    targets = lib.mkForce { };
    timers = lib.mkForce { };
  };

  manual.manpages.enable = false;
}
