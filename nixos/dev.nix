{ pkgs, config, ... }:

let
  inherit (config.my) username;
in {
  environment.systemPackages = with pkgs; [
    docker-compose
    python3
  ];

  programs = {
    adb.enable = true;
    # java = {
    #   enable = true;
    #   package = pkgs.jdk11;
    # };
  };

  virtualisation.docker.enable = true;

  # Added user to groups
  users.users.${username}.extraGroups = [ "docker" ];
}
