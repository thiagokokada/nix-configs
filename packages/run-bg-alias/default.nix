{
  stdenv,
  coreutils,
  writeShellApplication,
  command,
  name,
}:

writeShellApplication {
  inherit name;
  runtimeInputs = [ coreutils ];
  text =
    # macOS seems to lose the current PWD for some reason if you
    # close stdin, but without closing stdin you can't have a proper
    # background application.
    # This function should make it by expanding the paths, but it
    # is using a heuristic so it may be buggy.
    if stdenv.isDarwin then
      ''
        declare -a parsed_args

        while [[ "$#" -gt 0 ]]; do
          arg="$1"
          if [[ -d "$arg" ]] || [[ -f "$arg" ]]; then
            parsed_args+=("$(realpath "$arg")")
          else
            parsed_args+=("$arg")
          fi
          shift
        done

        exec 0>&-
        exec 1>&-
        exec 2>&-
        ${command} "''${parsed_args[@]}" &
        disown $!
      ''
    else
      ''
        exec 0>&-
        exec 1>&-
        exec 2>&-
        ${command} "$@" &
        disown $!
      '';
}
