{ lib, pkgs, ... }:
let
  privateKeyFile = "/etc/wireguard/wg-priv";
  wgGenerateConfig = pkgs.writeShellScriptBin "wg-generate-config" ''
    set -euo pipefail

    ENDPOINT="mirai-vps.duckdns.org:51820"
    SERVER_PUB_KEY="${privateKeyFile}"
    DNS="8.8.8.8, 8.4.4.8"

    usage() {
        cat <<EOF
    Usage: $(basename "$0") PROFILE IP_ADDRESS
    Generate Wireguard config.

    Example:
      $(basename "$0") profile-name 10.100.0.2
    EOF
        exit 1
    }

    generate_config() {
      local -r profile="$1"
      local -r address="$2"

      umask 077
      ${pkgs.wireguard}/bin/wg genkey | tee "$profile.key" \
        | ${pkgs.wireguard}/bin/wg pubkey > "$profile.key.pub"

      >&2 cat <<EOF >> "$profile.conf"
    [Interface]
    PrivateKey = $(cat "$profile.key")
    Address = $address/24
    DNS = $DNS

    [Peer]
    PublicKey = $SERVER_PUB_KEY
    AllowedIPs = 0.0.0.0/0
    Endpoint = $ENDPOINT
    EOF
    }

    generate_qr_code() {
      local -r profile="$1"
      ${pkgs.qrencode}/bin/qrencode -t ansiutf8 < "$profile.conf"
    }

    echoerr() { echo "$@" 1>&2; }

    main() {
      local -r profile="$1"
      local -r ip_address="$2"

      if [[ -f "$profile.conf" ]]; then
        echoerr "[WARNING] $profile profile already exists! Skipping config generation..."
      else
        generate_config "$profile" "$ip_address"
        echoerr "[INFO] Generated config:"
        cat "$profile.conf"
      fi
      echoerr

      echoerr "[INFO] Generated qr-code:"
      generate_qr_code "$profile"
      echoerr

      >&2 cat <<EOF
    [INFO] Done! Do not forget to add the following in your /etc/nixos/configuration.nix:
    networking.wireguard.interaces.*.peers = {
      publicKey = "$(cat "$profile.key.pub")";
      allowedIPs = [ "$2/32" ];
    };
    EOF
    }

    if [[ "$#" -le 1 ]]; then
      usage
    fi

    main $@
  '';
in
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
    wgGenerateConfig
  ];

  # enable NAT
  networking = {
    nat = {
      enable = true;
      externalInterface = lib.mkDefault "ens3";
      internalInterfaces = [ "wg0" ];
    };
    firewall.allowedUDPPorts = [ 51820 ];
    wireguard.interfaces = {
      wg0 = {
        inherit privateKeyFile;
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;

        peers = [
          {
            publicKey = "ZQzoQB1VFiTnpbCrBKk13gx6GHvoYFcGvF8p/Po7N2o=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
        ];
      };
    };
  };
}
