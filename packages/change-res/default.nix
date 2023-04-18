{ writeShellApplication
, autorandr
, mons
, systemd
}:

writeShellApplication {
  name = "change-res";
  runtimeInputs = [ autorandr mons systemd ];
  text = ''
    autorandr --change --default horizontal
    systemctl --user restart wallpaper.service
  '';
}
