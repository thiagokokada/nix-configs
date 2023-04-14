{ writeShellApplication
, autorandr
, mons
, systemd
}:

writeShellApplication {
  name = "change-res";
  runtimeInputs = [ autorandr mons systemd ];
  text = ''
    # Do not run this script in a Sway session
    if systemctl --quiet --user is-active sway-session.target; then
      exit 0
    fi
    autorandr --change || mons -o
    systemctl --user restart wallpaper.service
  '';
}
