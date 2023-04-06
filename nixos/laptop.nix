{ config, pkgs, lib, ... }:

{
  options.nixos.laptop.enable = lib.mkEnableOption "laptop config" // {
    default = (config.device.type == "laptop");
  };

  config = lib.mkIf config.nixos.laptop.enable {
    networking = {
      # Use Network Manager
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
        dispatcherScripts = [{
          source =
            let
              nmcli = "${pkgs.networkmanager}/bin/nmcli";
              logger = "${pkgs.inetutils}/bin/logger";
            in
            pkgs.writeText "wifi-wired-exclusive" ''
              IFACE="$1"
              ACTION="$2"

              log() { ${logger} -i -t "wifi-wired-exclusive" "$*"; }

              log "NetworkManager event: ''${IFACE:-NetworkManager} is $ACTION"
              case "$IFACE" in
                eth*|usb*|en*)
                  case "$ACTION" in
                    up)
                      log "Disabling wifi radio"
                      ${nmcli} radio wifi off
                      ;;
                    down)
                      log "Enabling wifi radio"
                      ${nmcli} radio wifi on
                      ;;
                  esac
                  ;;
              esac
            '';
          type = "basic";
        }];
      };
    };

    # Configure hibernation
    boot.resumeDevice = lib.mkIf (config.swapDevices != [ ])
      (lib.mkDefault (builtins.head config.swapDevices).device);

    # Install laptop related packages
    environment.systemPackages = with pkgs; [ iw ];

    # Configure special hardware in laptops
    hardware = {
      # Enable bluetooth
      bluetooth = { enable = true; };
    };

    # Enable programs that need special configuration
    programs = {
      # Enable NetworkManager applet
      nm-applet = { enable = true; };
    };

    # Make nm-applet restart in case of failure
    systemd.user.services.nm-applet = {
      serviceConfig = {
        RestartSec = 3;
        Restart = "on-failure";
      };
    };

    # Enable laptop specific services
    services = {
      # Enable Blueman to manage Bluetooth
      blueman = { enable = true; };

      # For battery status reporting
      upower = { enable = true; };

      # Only suspend on lid closed when laptop is disconnected
      logind = {
        # For hibernate to work you need to set
        # - `boot.resumeDevice` set to the swap partition/partition
        #   containing swap file
        # - If using swap file, also set
        #  `boot.kernelParams = [ "resume_offset=XXX" ]`
        lidSwitch = lib.mkDefault
          (if (config.boot.resumeDevice != "")
          then "suspend-then-hibernate"
          else "suspend");
        lidSwitchDocked = lib.mkDefault "ignore";
        lidSwitchExternalPower = lib.mkDefault "lock";
      };

      # Reduce power consumption
      tlp = {
        enable = true;
        settings = {
          # Disable USB autosuspend, since this seems to cause issues
          USB_AUTOSUSPEND = 0;
          # Powersave on battery
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          ENERGY_PERF_POLICY_ON_AC = "performance";
          ENERGY_PERF_POLICY_ON_BAT = "power";
        };
      };

      # Enable wakeup from USB devices
      udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTR{power/wakeup}="enabled"
      '';
    };
  };
}
