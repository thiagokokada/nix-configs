{ externalInterface
, wgPath
, wgEndpoint
, wgInterface ? "wg0"
, wgPort ? 51820
, wgHostIp ? "10.100.0.1"
, wgBroadcastIp ? "10.100.0.0"
, wgNetmask ? "24"
, dnsServers ? wgHostIp
}:
{ config, lib, pkgs, ... }:
let
  inherit (config.meta) configPath;
  privateKeyFile = "${wgPath}/wg-priv";
  publicKeyFile = "${wgPath}/wg-pub";
  wgPort = 51820;
  wgGenerateConfig = pkgs.writeShellScriptBin "wg-generate-config" ''
    set -euo pipefail

    usage() {
        cat <<EOF
    Usage: $(basename "$0") PROFILE IP_ADDRESS
    Generate Wireguard config.

    Server IP is: ${wgHostIp}/${wgNetmask}
    EOF
        exit 1
    }

    echoerr() { echo "$@" 1>&2; }

    generate_config() {
      local -r profile="$1"
      local -r address="$2"
      local -r server_pub_key="$(cat ${publicKeyFile})"
      local -r endpoint="${wgEndpoint}:${toString wgPort}"

      if [[ -f "$profile.conf" ]]; then
        echoerr "[WARNING] $profile profile already exists! Skipping wg config generation..."
        return
      fi

      umask 077
      ${pkgs.wireguard}/bin/wg genkey | tee "$profile.key" \
        | ${pkgs.wireguard}/bin/wg pubkey > "$profile.key.pub"

      >&2 cat <<EOF >> "$profile.conf"
    [Interface]
    PrivateKey = $(cat "$profile.key")
    Address = $address/${wgNetmask}
    DNS = ${dnsServers}

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
    { ... }:
    {
      networking.wireguard.interfaces.${wgInterface}.peers = [{
        publicKey = "$(cat "$profile.key.pub")";
        allowedIPs = [ "$address/32" ];
      }];
    }
    EOF

      chown "$owner" "$nixos_config"
    }

    main() {
      local -r profile="$1"
      local -r ip_address="$2"
      local -r nixos_config="${configPath}/nixos/wireguard/$profile.nix"

      pushd "${wgPath}/clients" >/dev/null
      trap "popd >/dev/null" EXIT

      generate_config "$profile" "$ip_address"
      echoerr "[INFO] Generated config:"
      cat "$profile.conf"
      echoerr

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
  imports = [
    ./s20.nix
  ];

  environment.systemPackages = with pkgs; [
    qrencode
    wgGenerateConfig
    wireguard
    wireguard-tools
  ];

  networking = {
    nat = {
      enable = true;
      inherit externalInterface;
      internalInterfaces = [ wgInterface ];
    };
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 wgPort ];
    };
    wireguard.interfaces = {
      wg0 = {
        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i ${wgInterface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${wgBroadcastIp}/${wgNetmask} -o ${externalInterface} -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i ${wgInterface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${wgBroadcastIp}/${wgNetmask} -o ${externalInterface} -j MASQUERADE
        '';

        inherit privateKeyFile;
        ips = [ "${wgHostIp}/${wgNetmask}" ];
        listenPort = wgPort;
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      interface=${wgInterface}
    '';
  };
}
