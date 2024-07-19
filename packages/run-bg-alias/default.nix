{
  writeShellApplication,
  coreutils,
  daemonize,
  name,
  command,
}:

writeShellApplication {
  inherit name;
  runtimeInputs = [
    coreutils
    daemonize
  ];
  text = # bash
    ''
      cmd="$(basename ${command})"
      tmpdir="$(mktemp "bg-$cmd.XXXXXX" -d --tmpdir="''${TMPDIR:-}")"
      daemonize -o "$tmpdir/stdout" -e "$tmpdir/stderr" -c "$PWD" "${command}" "$@"
    '';
}
