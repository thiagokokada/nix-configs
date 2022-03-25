{ externalInterface
, wgEndpoint
, wgPath ? "/etc/wireguard"
, wgInterface ? "wg0"
, wgPort ? 51820
, wgHostIp ? "10.100.0.1"
, wgNetmask ? "24"
, wgDnsServers ? wgHostIp
, useHostDNS ? (wgDnsServers == wgHostIp)
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
    Usage: $(${pkgs.coreutils}/bin/basename "$0") PROFILE IP_ADDRESS
    Generate Wireguard config and print it on terminal (with QR code for mobile devices).

    WARNING: this will show the client private key!

    PROFILE should be an easy to remember name. This is used to generate filenames.

    IP_ADDRESS should be a unique and valid IP inside the Wireguard network.
    The current Host Wireguard's IP is '${wgHostIp}/${wgNetmask}'.
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

      if [[ -f "$profile.conf" ]]; then
        echoerr "[WARNING] $profile profile already exists! Skipping config generation..."
        return
      fi

      # Since those are private keys, they need to be only visible by root
      # for security
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

      # "Undo" changes from `generate_config` function
      umask 022
      cat <<EOF > "$nixos_config"
    {
      publicKey = "$(cat "$profile.key.pub")";
      allowedIPs = [ "$address/32" ];
    }
    EOF

      # Most of times this script will run as root, but the NixOS config directory
      # is not necessary owned by root
      ${pkgs.coreutils}/bin/chown "$owner" "$nixos_config"
    }

    main() {
      local -r profile="$1"
      local -r ip_address="$2"
      local -r nixos_config="${configPath}/nixos/wireguard/$profile.nix"

      mkdir -p "${wgClientsPath}"
      pushd "${wgClientsPath}" >/dev/null
      trap "popd >/dev/null" EXIT

      generate_config "$profile" "$ip_address"
      echoerr "[INFO] Generated config:"
      echoerr "============================================================"
      cat "$profile.conf"
      echoerr "============================================================"
      echoerr

      echoerr "[INFO] Generated qr-code:"
      generate_qr_code "$profile"
      echoerr

      generate_nix_config "$profile" "$ip_address" "$nixos_config"
      echoerr "[INFO] Done! Do not forget to import './$profile.nix' file in '${configPath}/nixos/wireguard/default.nix'"
    }

    if [[ "$#" -le 1 ]]; then
      usage
    fi

    if [[ "$EUID" -ne 0 ]];then
      echoerr "[ERROR] Please run this script as root!"
      exit 1
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

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking = {
    nat = {
      enable = true;
      inherit externalInterface;
      internalInterfaces = [ wgInterface ];
    };
    firewall = {
      # Port 53 is for DNS
      allowedTCPPorts = lib.optional useHostDNS 53;
      allowedUDPPorts = [ wgPort 53 ] ++ lib.optional useHostDNS 53;
    };
    wireguard.interfaces = {
      ${wgInterface} = {
        inherit privateKeyFile;
        ips = [ "${wgHostIp}/${wgNetmask}" ];
        listenPort = wgPort;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i ${wgInterface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s '${wgHostIp}/${wgNetmask}' -o ${externalInterface} -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i ${wgInterface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s '${wgHostIp}/${wgNetmask}' -o ${externalInterface} -j MASQUERADE
        '';

        # Generate with `wg-generate-config` script
        peers = [
          (import ./s20.nix)
          (import ./tabs8.nix)
        ];
      };
    };
  };

  # If you want to use the host for DNS resolution (more secure), we need to
  # enable dnsmasq to serve as a DNS server
  services.dnsmasq = lib.mkIf useHostDNS {
    enable = true;
    extraConfig = ''
      interface=${wgInterface}
    '';
  };
}
