{ pkgs, config, ... }:

let
  inherit (config.my) username;
in {
  environment.systemPackages = with pkgs; [
    binutils
    cmake
    docker-compose
    emacsCustom
    expect
    gcc
    gitFull
    github-cli
    gnumake
    neovimCustom
    python3Full
  ];

  programs.adb.enable = true;

  virtualisation.docker.enable = true;

  # Added user to groups
  users.users.${username}.extraGroups = [ "docker" ];
}
