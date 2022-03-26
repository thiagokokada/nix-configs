{ externalInterface
, externalUrl
, wgPath ? "/etc/wireguard"
, wgInterface ? "wg0"
, wgPort ? 51820
, wgHostIp ? "10.100.0.1"
, wgNetmask ? "24"
, wgHostIp6 ? "fdc9:281f:04d7:9ee9::1"
, wgNetmask6 ? "64"
, wgDnsServers ? "${wgHostIp}, ${wgHostIp6}"
, useHostDNS ? (wgDnsServers == "${wgHostIp}, ${wgHostIp6}")
}:
{ config, lib, pkgs, ... }:
let
  inherit (config.meta) configPath;
  privateKeyFile = "${wgPath}/wg-priv";
  publicKeyFile = "${wgPath}/wg-pub";
  wgClientsPath = "${wgPath}/clients";
  wgGenerateConfig = pkgs.writeShellScriptBin "wg-generate-config" ''
    set -euo pipefail

    declare -r ENDPOINT="${externalUrl}:${toString wgPort}"

    usage() {
        local -r program_name="$(${pkgs.coreutils}/bin/basename "$0")"
        cat <<EOF
    Usage: $program_name PROFILE IP_ADDRESS [IPV6_ADDRESS]
    Generate Wireguard config and print it on terminal (with QR code for mobile devices).

    WARNING: this will show the client private key!

    PROFILE should be an easy to remember name. This is used to generate filenames.

    IP_ADDRESS/IPV6_ADDRESS should be an unique and valid IP inside the Wireguard network.
    The current host Wireguard configuration is:
    - Endpoint: $ENDPOINT
    - Host IPv4: ${wgHostIp}/${wgNetmask}
    - Host IPv6: ${wgHostIp6}/${wgNetmask6}

    Examples:
    # If host IPv4 is '10.100.0.1/24'
    $program_name device 10.100.0.2
    # If host IPv4 is '10.100.0.1/24' and IPv6 is 'fdc9:281f:04d7:9ee9::1/64'
    $program_name device 10.100.0.2 fdc9:281f:04d7:9ee9::2
    EOF
        exit 1
    }

    echoerr() { echo "$@" 1>&2; }

    generate_config() {
      local -r profile="$1"
      local -r ip_address="$2"
      local -r ipv6_address="$3"
      local -r server_pub_key="$(cat ${publicKeyFile})"
      local -r dns="${wgDnsServers}"

      if [[ -f "$profile.key" ]]; then
        echoerr "[WARNING] '$profile' private key already exists! Skipping key generation..."
      else
        # Since those are private keys, they need to be only visible by root
        # for security
        umask 077
        ${pkgs.wireguard}/bin/wg genkey | tee "$profile.key" \
          | ${pkgs.wireguard}/bin/wg pubkey > "$profile.key.pub"
      fi

      local ip_addresses
      if [[ -z "$ipv6_address" ]]; then
        ip_addresses="$ip_address/${wgNetmask}"
      else
        ip_addresses="$ip_address/${wgNetmask}, $ipv6_address/${wgNetmask6}"
      fi

      cat <<EOF > "$profile.conf"
    [Interface]
    PrivateKey = $(cat "$profile.key")
    Address = $ip_addresses
    DNS = $dns

    [Peer]
    PublicKey = $server_pub_key
    AllowedIPs = 0.0.0.0/0, ::/0
    Endpoint = $ENDPOINT
    EOF
    }

    generate_qr_code() {
      local -r profile="$1"
      ${pkgs.qrencode}/bin/qrencode -t ansiutf8 < "$profile.conf"
    }

    generate_nixos_config() {
      local -r profile="$1"
      local -r ip_address="$2"
      local -r ipv6_address="$3"
      local -r nixos_config="$4"
      # Get the current '<user>:<group>' from NixOS's config path
      local -r owner="$(stat -c '%U:%G' '${configPath}')"

      local ip_addresses
      if [[ -z "$ipv6_address" ]]; then
        ip_addresses="\"$ip_address/32\""
      else
        ip_addresses="\"$ip_address/32\" \"$ipv6_address/128\""
      fi

      # "Undo" changes from `generate_config` function
      umask 022
      cat <<EOF > "$nixos_config"
    {
      publicKey = "$(cat "$profile.key.pub")";
      allowedIPs = [ $ip_addresses ];
    }
    EOF

      # Most of times this script will run as root, but the NixOS config directory
      # is not necessary owned by root
      ${pkgs.coreutils}/bin/chown "$owner" "$nixos_config"
    }

    main() {
      local -r profile="$1"
      local -r ip_address="$2"
      local -r ipv6_address="''${3:-}"

      mkdir -p "${wgClientsPath}"
      pushd "${wgClientsPath}" >/dev/null
      trap "popd >/dev/null" EXIT

      generate_config "$profile" "$ip_address" "$ipv6_address"
      echoerr "[INFO] Generated config:"
      echoerr "============================================================"
      cat "$profile.conf"
      echoerr "============================================================"
      echoerr

      echoerr "[INFO] Generated qr-code:"
      generate_qr_code "$profile"
      echoerr

      local -r nixos_config_path="${configPath}/nixos/wireguard/${externalUrl}"
      mkdir -p "$nixos_config_path"
      local -r nixos_config="$nixos_config_path/$profile.nix"

      generate_nixos_config "$profile" "$ip_address" "$ipv6_address" "$nixos_config"
      echoerr "[INFO] Done! Do not forget to import './$profile.nix' file in '${configPath}/nixos/wireguard/${externalUrl}'"
    }

    if [[ "$#" -lt 2 ]]; then
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
  imports = [
    (import ./${externalUrl} { inherit wgInterface; })
    ../../modules/meta.nix
  ];

  environment.systemPackages = with pkgs; [
    qrencode
    wgGenerateConfig
    wireguard
    wireguard-tools
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
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
        ips = [ "${wgHostIp}/${wgNetmask}" "${wgHostIp6}/${wgNetmask6}" ];
        listenPort = wgPort;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s '${wgHostIp}/${wgNetmask}' -o ${externalInterface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s '${wgHostIp6}/${wgNetmask6}' -o ${externalInterface} -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s '${wgHostIp}/${wgNetmask}' -o ${externalInterface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s '${wgHostIp6}/${wgNetmask6}' -o ${externalInterface} -j MASQUERADE
        '';
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
