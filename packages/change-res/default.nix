{ writeShellApplication
, autorandr
, mons
, systemd
}:

writeShellApplication {
  name = "change-res";
  runtimeInputs = [ autorandr mons systemd ];
  text = ''
    autorandr --change || mons -o
    systemctl --user restart wallpaper.service
  '';
}
