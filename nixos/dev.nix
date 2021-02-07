{ pkgs, config, ... }:

{
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

  # Enable adb
  programs.adb.enable = true;

  virtualisation = {
    # Enable Docker.
    docker.enable = true;
  };

  # Added user to groups.
  users.users.thiagoko.extraGroups = [ "docker" ];
}
