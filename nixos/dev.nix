{ pkgs, config, ... }:

let
  inherit (config.my) username;
in {
  environment.systemPackages = with pkgs; [
    docker-compose
    gcc
    git
    gnumake
    neovim-custom
    python3
  ];

  programs.adb.enable = true;

  virtualisation.docker.enable = true;

  # Added user to groups
  users.users.${username}.extraGroups = [ "docker" ];
}
