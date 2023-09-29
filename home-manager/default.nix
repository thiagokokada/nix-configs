{ ... }:

{
  imports = [
    ./desktop
    ./dev
    ./minimal.nix
    ./theme
  ];

  # More reliable user service restart
  systemd.user.startServices = "sd-switch";
}
