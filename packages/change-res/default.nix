{ writeShellApplication
, autorandr
, systemd
}:

writeShellApplication {
  name = "change-res";
  runtimeInputs = [ autorandr systemd ];
  text = ''
    # Do not run this script in a Sway session
    if systemctl --quiet --user is-active sway-session.target; then
      exit 0
    fi
    autorandr --change || autorandr common
    systemctl --user restart wallpaper.service
  '';
}
