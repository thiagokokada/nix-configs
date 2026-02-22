{
  pkgs,
  lib,
  config,
  flake,
  ...
}:

let
  inherit (config.nixos.home) username;
  cfg = config.nixos.games.rocksmith;
in
{
  imports = [
    flake.inputs.nixos-rocksmith.nixosModules.default
  ];
  options.nixos.games.rocksmith.enable = lib.mkEnableOption "RockSmith 2014 config";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      helvum # Lets you view pipewire graph and connect IOs
      rtaudio
    ];

    # Add user to `audio` and `rtkit` groups.
    users.users.${username}.extraGroups = [
      "audio"
      "rtkit"
    ];

    programs.steam.rocksmithPatch.enable = true;
  };
}
