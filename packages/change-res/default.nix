{ writeShellApplication
, autorandr
, mons
, systemd
}:

writeShellApplication {
  name = "change-res";
  runtimeInputs = [ autorandr mons systemd ];
  text = ''
    autorandr --change --default default
  '';
}
