{ pkgs, lib, config, ... }:

let
  cfg = config.nixos.games.osu;
in
{
  options.nixos.games.osu.enable = lib.mkEnableOption "osu! config";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; let
      import-osu-songs = pkgs.writeShellApplication {
        name = "import-osu-songs";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          declare -r osu_dir="$HOME/.osu"
          if [[ ! -d "$osu_dir" ]]; then
            >&2 echo "'$osu_dir' directory not found! Start 'osu-stable' once to create it."
            exit 1
          fi
          declare -r osu_song_dir="$osu_dir/drive_c/osu/Songs"
          mkdir -p "$osu_song_dir"
          cp -v "''${@}" "$osu_song_dir"
        '';
      };
    in
    [
      gaming.osu-lazer-bin
      gaming.osu-stable
      import-osu-songs
    ];

    # Enable opentabletdriver
    hardware.opentabletdriver.enable = true;
  };
}
