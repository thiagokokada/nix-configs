{ homeManagerConfiguration, ... }:

let
  inherit (homeManagerConfiguration) config pkgs;
  inherit (config.home) homeDirectory packages profileDirectory;
in
pkgs.mkShell {
  # Ensure that nix/nix-build is in PATH
  packages = [ pkgs.nix ] ++ packages;
  shellHook = ''
    export HOME=${homeDirectory}
    mkdir -p "$HOME"

    if ${homeManagerConfiguration.activationPackage}/activate; then
      . ${profileDirectory}/etc/profile.d/hm-session-vars.sh
      zsh -l && exit 0
    else
      >&2 echo "[ERROR] Could not activate Home Manager!"
      >&2 echo "[ERROR] Did you pass '--impure' flag to 'nix develop'?"
      >&2 echo "[INFO] You can run the following command manually to debug the issue:"
      >&2 echo "[INFO] $ ${homeManagerConfiguration.activationPackage}/activate"
    fi
  '';
}
