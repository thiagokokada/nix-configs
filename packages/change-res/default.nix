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
      echo "Sway session is active, skipping resolution change..."
      exit 1
    fi
    autorandr --change --default default
  '';
}
