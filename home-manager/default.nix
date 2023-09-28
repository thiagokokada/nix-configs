{ ... }:

{
  imports = [
    ./cli
    ./desktop
    ./emacs
    ./i3
    ./kitty.nix
    ./meta
    ./mpv
    ./nixpkgs.nix
    ./non-nix.nix
    ./sway
    ./theme
    ./xterm.nix
  ];

  systemd.user.startServices = "sd-switch";
}
