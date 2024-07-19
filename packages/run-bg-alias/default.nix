{
  writeShellApplication,
  daemonize,
  which,
  name,
  command,
}:

writeShellApplication {
  inherit name;
  runtimeInputs = [
    daemonize
    which
  ];
  text = ''
    daemonize -c "$PWD" "$(which "${command}")" "$@"
  '';
}
