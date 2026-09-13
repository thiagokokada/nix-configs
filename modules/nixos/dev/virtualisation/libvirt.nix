{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.nixos.home) username;
  cfg = config.nixos.dev.virtualisation.libvirt;
in
{
  options.nixos.dev.virtualisation.libvirt = {
    enable = lib.mkEnableOption "libvirt config" // {
      default = config.nixos.dev.virtualisation.enable;
    };
    vfioPci = {
      enable = lib.mkEnableOption "vfio-pci (PCI passthrough)";
      ids = lib.mkOption {
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
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        # https://wiki.nixos.org/wiki/Libvirt#Default_networking
        dnsmasq
        gnome-boxes
      ];

      # Not completely sure if this is needed but should fix some NAT issues
      networking.firewall.checkReversePath = "loose";

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            swtpm.enable = true;
          };
        };

        spiceUSBRedirection.enable = true;
      };

      users.users.${username}.extraGroups = [ "libvirtd" ];
    }
    (lib.mkIf cfg.vfioPci.enable {
      boot = {
        initrd.kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
          "vfio_virqfd"
        ];
        kernelParams = [
          "rd.driver.pre=vfio-pci"
        ]
        ++ lib.optionals (cfg.vfioPci != [ ]) [
          "vfio-pci.ids=${lib.concatStringsSep "," cfg.vfioPci.ids}"
        ];
      };

      programs.virt-manager.enable = true;

      environment.systemPackages =
        let
          iommu-script = pkgs.writeShellScriptBin "iommu" ''
            for d in /sys/kernel/iommu_groups/*/devices/*; do
              n=''${d#*/iommu_groups/*}; n=''${n%%/*}
              printf 'IOMMU Group %s ' "$n"
              lspci -nns "''${d##*/}"
            done
          '';
        in
        [
          iommu-script
        ];

      # Very likely we want the desktop session if we are using libvirt
      nixos.games.jovian.bootInDesktopMode = true;

      # Disable early KMS
      # TODO: make this works for other GPU makers
      jovian.hardware.amd.gpu.enableEarlyModesetting = false;
      hardware.amdgpu.initrd.enable = false;
    })
  ];
}
