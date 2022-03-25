{ externalInterface
, wgEndpoint
, wgPath ? "/etc/wireguard"
, wgInterface ? "wg0"
, wgPort ? 51820
, wgHostIp ? "10.100.0.1"
, wgNetmask ? "24"
, wgDnsServers ? "8.8.8.8, 8.4.4.8"
}:
{ config, lib, pkgs, ... }:
let
  inherit (config.meta) configPath;
  privateKeyFile = "${wgPath}/wg-priv";
  publicKeyFile = "${wgPath}/wg-pub";
  wgClientsPath = "${wgPath}/clients";
  wgGenerateConfig = pkgs.writeShellScriptBin "wg-generate-config" ''
    set -euo pipefail

    usage() {
        cat <<EOF
    Usage: $(basename "$0") PROFILE IP_ADDRESS
    Generate Wireguard config.

    Server IP: ${wgHostIp}/${wgNetmask}

    EOF
        exit 1
    }

    echoerr() { echo "$@" 1>&2; }

    generate_config() {
      local -r profile="$1"
      local -r address="$2"
      local -r endpoint="${wgEndpoint}:${toString wgPort}"
      local -r server_pub_key="$(cat ${publicKeyFile})"
      local -r dns="${wgDnsServers}"

      pushd "${wgClientsPath}" >/dev/null
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

    generate_nix_config() {
      local -r profile="$1"
      local -r address="$2"
      local -r nixos_config="$3"
      local -r owner="$(stat -c '%U:%G' '${configPath}')"
      if [[ -f "$nixos_config" ]]; then
        echoerr "[WARNING] $nixos_config file already exists! Skipping config file generation..."
        return
      fi
      umask 022
      cat <<EOF > "$nixos_config"
    {
      publicKey = "$(cat "$profile.key.pub")";
      allowedIPs = [ "$address/32" ];
    }
    EOF
      chown "$owner" "$nixos_config"
    }

    main() {
      local -r profile="$1"
      local -r ip_address="$2"
      local -r nixos_config="${configPath}/nixos/wireguard/$profile.nix"

      generate_config "$profile" "$ip_address"
      echoerr "[INFO] Generated config:"
      cat "$profile.conf"

      echoerr "[INFO] Generated qr-code:"
      generate_qr_code "$profile"
      echoerr

      generate_nix_config "$profile" "$ip_address" "$nixos_config"
      echoerr "[INFO] Done! Do not forget to import './$profile.nix' file in '$nixos_config'"
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
      inherit externalInterface;
      internalInterfaces = [ wgInterface ];
    };
    firewall.allowedUDPPorts = [ wgPort ];
    wireguard.interfaces = {
      ${wgInterface} = {
        inherit privateKeyFile;
        ips = [ "${wgHostIp}/${wgNetmask}" ];
        listenPort = wgPort;

        peers = [
          (import ./s20.nix)
        ];
      };
    };
  };
}
