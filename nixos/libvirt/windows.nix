{ config, lib, pkgs, ... }:

let
  helpers = pkgs.callPackage ./helpers.nix { };
in
{
  environment.systemPackages = with pkgs; [
    (helpers.startVmScript "windows" "0-1")
    (helpers.stopVmScript "windows" "0-5")
  ];

  systemd.services.setup-windows-vm = {
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    # Run this manually to avoid overwritting manually setup configuration
    # wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script =
      let
        targetDisk = "/dev/disk/by-id/dm-name-enc-windows";
      in
      ''
        uuid="$(${pkgs.libvirt}/bin/virsh domuuid windows || true)"
        xml=$(sed -e "s|@UUID@|$uuid|" -e "s|@DISK@|${targetDisk}|" ${./windows.xml})
        ${pkgs.libvirt}/bin/virsh define <(echo "$xml")
      '';
  };
}
