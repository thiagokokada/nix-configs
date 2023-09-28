{ ... }:

{
  imports = [
    ./cli
    ./desktop
    ./emacs
    ./i3
    ./meta
    ./mpv
    ./nixpkgs.nix
    ./non-nix.nix
    ./sway
    ./theme
  ];

  systemd.user.startServices = "sd-switch";
}
