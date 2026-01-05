{
  writeShellApplication,
  coreutils,
  name,
  command,
}:

writeShellApplication {
  inherit name;
  runtimeInputs = [ coreutils ];
  text = ''
    cwd="$PWD"
    cmd="$(basename ${command})"
    tmpdir="$(mktemp "run-bg-$cmd.XXXXXX" -d --tmpdir="''${TMPDIR:-}")"

    (
      cd "$cwd"
      nohup ${command} "$@" </dev/null >"$tmpdir/stdout" 2>"$tmpdir/stderr" &
      pid=$!
      echo "Running '$cmd' in background (pid: $pid). Logs: $tmpdir"
    ) &
  '';
}
