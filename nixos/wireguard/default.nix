{ lib, pkgs, ... }:
let
  wgPath = "/etc/wireguard";
  privateKeyFile = "${wgPath}/wg-priv";
  publicKeyFile = "${wgPath}/wg-pub";
  wgEndpoint = "mirai-vps.duckdns.org";
  wgPort = 51820;
  wgGenerateConfig = pkgs.writeShellScriptBin "wg-generate-config" ''
    set -euo pipefail

    usage() {
        cat <<EOF
    Usage: $(basename "$0") PROFILE IP_ADDRESS
    Generate Wireguard config.

    Example:
      $(basename "$0") profile-name 10.100.0.2
    EOF
        exit 1
    }

    echoerr() { echo "$@" 1>&2; }

    generate_config() {
      local -r profile="$1"
      local -r address="$2"
      local -r endpoint="${wgEndpoint}:${toString wgPort}"
      local -r server_pub_key="$(cat ${publicKeyFile})"
      local -r dns="8.8.8.8, 8.4.4.8"

      pushd "${wgPath}/clients" >/dev/null
      trap "popd >/dev/null" EXIT

      if [[ -f "$profile.conf" ]]; then
        echoerr "[WARNING] $profile profile already exists! Skipping config generation..."
        return 1
      fi

      umask 077
      ${pkgs.wireguard}/bin/wg genkey | tee "$profile.key" \
        | ${pkgs.wireguard}/bin/wg pubkey > "$profile.key.pub"

      >&2 cat <<EOF >> "$profile.conf"
    [Interface]
    PrivateKey = $(cat "$profile.key")
    Address = $address/24
    DNS = $dns

    [Peer]
    PublicKey = $server_pub_key
    AllowedIPs = 0.0.0.0/0
    Endpoint = $endpoint
    EOF
    }

    generate_qr_code() {
      local -r profile="$1"
      ${pkgs.qrencode}/bin/qrencode -t ansiutf8 < "$profile.conf"
    }

    main() {
      local -r profile="$1"
      local -r ip_address="$2"

      generate_config "$profile" "$ip_address"
      echoerr "[INFO] Generated config:"
      cat "$profile.conf"

      echoerr "[INFO] Generated qr-code:"
      generate_qr_code "$profile"
      echoerr

      >&2 cat <<EOF
    [INFO] Done! Do not forget to add the following in your /etc/nixos/configuration.nix:
    networking.wireguard.interaces.*.peers = [{
      publicKey = "$(cat "$profile.key.pub")";
      allowedIPs = [ "$2/32" ];
    }];
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
    qrencode
    wgGenerateConfig
    wireguard
    wireguard-tools
  ];

  # enable NAT
  networking = {
    nat = {
      enable = true;
      externalInterface = lib.mkDefault "ens3";
      internalInterfaces = [ "wg0" ];
    };
    firewall.allowedUDPPorts = [ wgPort ];
    wireguard.interfaces = {
      wg0 = {
        inherit privateKeyFile;
        ips = [ "10.100.0.1/24" ];
        listenPort = wgPort;

        peers = [
          {
            publicKey = "2n3Vkr5APUYHa8qzAxbiwtg5WCKimzjX8PQ/hiWoXis=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
        ];
      };
    };
  };
}
