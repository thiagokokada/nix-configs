{ pkgs, lib, ... }:

# Shell helpers
rec {

  # Run command in background
  # Keep in mind that args will follow shell splitting rules
  runBgCmd = command: args:
    "${command} ${args} </dev/null &>/dev/null &!";

  # macOS seems to lose the current PWD for some reason if you
  # close stdin, but without closing stdin you can't have a proper
  # background application.
  # This function should make it wirj by expanding the paths, but it
  # is using a heuristic so it may be buggy.
  makeBgCmd = alias: command:
    let
      realpath = "${pkgs.coreutils}/bin/realpath";
    in
    if pkgs.stdenv.isDarwin then ''
      ${alias}() {
        local -a parsed_args

        while [[ "$#" -gt 0 ]]; do
          arg="$1"
          case "$arg" in
            # Either a hidden file or a relative path
            .?*)
              parsed_args+=("$(${realpath} "$arg")")
              shift
              ;;
            # a/file
            *?/?*)
              parsed_args+=("$(${realpath} "$arg")")
              shift
              ;;
            # Probably an option
            -?*)
              parsed_args+=("$arg")
              shift
              ;;
            # Something else, check if it is a file or not
            *)
              if [[ -d "$arg" ]] || [[ -f "$arg" ]]; then
                parsed_args+=("$(${realpath} "$arg")")
              else
                parsed_args+=("$arg")
              fi
              shift
              ;;
          esac
        done

        ${runBgCmd command ''"''${parsed_args[@]}"''}
      }
    '' else ''
      ${alias}() {
        ${runBgCmd command ''"''${parsed_args[@]}"''}
      }
    '';
}
