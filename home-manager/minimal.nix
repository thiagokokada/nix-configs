{ pkgs, lib, ... }:

{
  imports = [ ./default.nix ];

  # Need to be set since meta module is disabled in this config
  home.stateVersion = "23.11";

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
  home.activation = {
    reloadSystemd = lib.mkIf pkgs.stdenv.isLinux
      (lib.mkForce (lib.hm.dag.entryAnywhere ""));
    setupLaunchAgents = lib.mkIf pkgs.stdenv.isDarwin
      (lib.mkForce (lib.hm.dag.entryAnywhere ""));
  };
  systemd.user = lib.mkForce { };
  # Disable macOS's launchd services
  launchd.enable = false;

  # Disable manpages to reduce closure size
  manual.manpages.enable = false;
}
