# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, system, ... }:

let inherit (config.my) username;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../nixos/cli.nix
      ../../nixos/misc.nix
      ../../nixos/security.nix
      ../../nixos/ssh.nix
      ../../nixos/system.nix
      ../../nixos/user.nix
      ../../nixos/vps.nix
      ../../modules/my.nix
      ../../cachix.nix
      ../../overlays
      inputs.home.nixosModules.home-manager
    ];

  home-manager = {
    useUserPackages = true;
    users.${username} = {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      home.stateVersion = "20.09";
      imports = [
        ../../home-manager/git.nix
        ../../home-manager/irssi.nix
        ../../home-manager/neovim.nix
        ../../home-manager/tmux.nix
        ../../home-manager/zsh.nix
        ../../overlays
      ];
    };
    extraSpecialArgs = {
      inherit inputs system;
      super = config;
    };
  };

  users.extraUsers.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2emux6tprbzXmtykaW44sSd4o7e7E2wAWZMFBSUb87 thiagokokada@gmail.com"
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "mirai-vps";
}
