{ ... }:

{
  imports = [
    ./desktop
    ./i3
    ./minimal.nix
    ./mpv
    ./nixpkgs.nix
    ./non-nix.nix
    ./sway
    ./theme
  ];

  systemd.user.startServices = "sd-switch";
}
