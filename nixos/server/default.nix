{ lib, config, pkgs, ... }:
{
  options.nixos.server.enable = lib.mkEnableOption "server config" // {
    default = (config.device.type == "server");
  };

  imports = [
    ./duckdns-updater.nix
    ./iperf3.nix
    ./jellyfin.nix
    ./networkd.nix
    ./plex.nix
    ./rtorrent.nix
    ./samba.nix
    ./ssh.nix
    ./tailscale.nix
  ];

  config = lib.mkIf config.nixos.server.enable {
    # Enable watchdog
    systemd.watchdog = {
      runtimeTime = "1m";
      rebootTime = "10m";
    };
    # Enable NixOS auto-upgrade
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:thiagokokada/nix-configs";
    };
    environment.systemPackages = with pkgs; [
      # Run nixos-rebuild inside a systemd-run to avoid TTY closing issues
      # https://github.com/NixOS/nixpkgs/issues/39118
      (writeShellScriptBin "nixos-rebuild" ''
        if [[ -z "$NIXOS_REBUILD_FALLBACK" ]] && [[ -z "$SSH_CLIENT" ]] && [[ "$#" -ne 0 ]]; then
          systemd-run \
                -E NIX_PATH \
                -E LOCALE_ARCHIVE \
                -E PATH \
                --unit=nixos-rebuild --pty --wait --collect --same-dir --service-type=exec \
                "${nixos-rebuild}/bin/nixos-rebuild" "$@"
        else
          "${nixos-rebuild}/bin/nixos-rebuild" "$@"
        fi
      '')
    ];
  };
}
