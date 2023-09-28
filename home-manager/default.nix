{ ... }:

{
  imports = [
    ./desktop
    ./i3
    ./minimal.nix
    ./sway
    ./theme
  ];

  systemd.user.startServices = "sd-switch";
}
