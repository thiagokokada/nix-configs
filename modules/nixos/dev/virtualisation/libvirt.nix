{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.nixos.home) username;
  cfg = config.nixos.dev.virtualisation.libvirt;
  iommu-script = pkgs.writeShellScriptBin "iommu" ''
    for d in /sys/kernel/iommu_groups/*/devices/*; do
      n=''${d#*/iommu_groups/*}; n=''${n%%/*}
      printf 'IOMMU Group %s ' "$n"
      lspci -nns "''${d##*/}"
    done
  '';
in
{
  options.nixos.dev.virtualisation.libvirt = {
    enable = lib.mkEnableOption "libvirt config";
    vfioPci.ids = lib.mkOption {
      type = with lib.types; listOf str;
      description = "PCI-e devices that will be passthrough to the VM.";
      # run iommu-script to get the devices and groups
      example = [
        "1002:67b0"
        "1002:aac8"
      ];
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    specialisation.libvirt.configuration = {
      # Very likely we want the desktop session if we are using libvirt
      nixos.games.jovian.bootInDesktopMode = true;

      boot.kernelParams = lib.optionals (cfg.vfioPci != [ ]) [
        "vfio-pci.ids=${lib.concatStringsSep "," cfg.vfioPci.ids}"
      ];

      environment.systemPackages = with pkgs; [
        # https://wiki.nixos.org/wiki/Libvirt#Default_networking
        dnsmasq
        iommu-script
      ];

      programs.virt-manager.enable = true;

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            swtpm.enable = true;
            ovmf = {
              enable = true;
              packages = with pkgs; [ OVMFFull.fd ];
            };
          };
        };

        spiceUSBRedirection.enable = true;
      };

      users.users.${username}.extraGroups = [ "libvirtd" ];
    };
  };
}
