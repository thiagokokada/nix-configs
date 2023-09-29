{ ... }:

{
  imports = [
    ./desktop
    ./dev
    ./i3
    ./minimal.nix
    ./sway
    ./theme
  ];

  # More reliable user service restart
  systemd.user.startServices = "sd-switch";
}
