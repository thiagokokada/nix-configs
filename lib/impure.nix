{ ... }:

{
  # Needs to run with `--impure because `builtins.getEnv`
  getEnvOrDefault = env: default:
    let
      envValue = builtins.getEnv env;
    in
    if envValue != "" then envValue else default;
}
