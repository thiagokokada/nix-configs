{ pkgs, ... }:

rec {
  # ZSH helpers

  # Run command in background
  # Keep in mind that args will follow shell splitting rules
  runBgCmd = command: args:
    "${command} ${args} </dev/null &>/dev/null &!";

  # macOS seems to loose the current PWD for some reason if you
  # close stdin, but without closing stdin you can't have a proper
  # background application.
  # This function should make it safer by expanding the paths.
  makeBgCmd = alias: command:
    let
      realpath = "${pkgs.coreutils}/bin/realpath";
    in
    ''
      ${alias}() {
        local -a parsed_args
        local arg_real_path

        for arg in "$@"; do
          if [[ -d "$arg" ]] || [[ -f "$arg" ]]; then
            parsed_args+=("$(${realpath} "$arg")")
          else
            parsed_args+=("$arg")
          fi
        done

        ${runBgCmd command ''"''${parsed_args[@]}"''}
      }
    '';
}
