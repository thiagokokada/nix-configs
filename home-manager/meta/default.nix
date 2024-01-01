{ config, lib, pkgs, osConfig, ... }:

{
  imports = [
    ./home-manager-auto-expire.nix
    ./diff.nix
  ];

  options.home-manager.meta.enable = lib.mkEnableOption "Home-Manager config" // {
    default = true;
  };

  config = lib.mkIf config.home-manager.meta.enable {
    # Add some Nix related packages
    home.packages = with pkgs; [
      nix-cleanup
      nix-whereis
    ];

    # To make cachix work you need add the current user as a trusted-user on Nix
    # sudo echo "trusted-users = $(whoami)" >> /etc/nix/nix.conf
    # Another option is to add a group by prefixing it by @, e.g.:
    # sudo echo "trusted-users = @wheel" >> /etc/nix/nix.conf
    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = lib.mkMerge [
        (import ../../shared/nix-conf.nix)
        (import ../../shared/substituters.nix)
      ];
    };

    # Config for ad-hoc nix commands invocation
    xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

    programs = {
      # Let Home Manager install and manage itself
      home-manager.enable = true;
      # Without git we may be unable to build this config
      git.enable = true;
    };

    services.home-manager.autoExpire = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      timestamp = "-7 days";
      frequency = "3:05";
      store.cleanup = true;
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = osConfig.system.stateVersion or "23.11";

    # More reliable user service restart
    systemd.user.startServices = lib.mkIf pkgs.stdenv.isLinux "sd-switch";

    manual.html.enable = true;
  };
}
