{ writeShellApplication, autorandr }:

writeShellApplication {
  name = "change-res";
  runtimeInputs = [ autorandr ];
  text = ''
    autorandr --change --default default
  '';
}
