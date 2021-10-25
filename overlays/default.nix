{ pkgs, lib, self, system, ... }:

let
  inherit (self) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-autobahn = self.inputs.nix-autobahn.defaultPackage.${system};

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nixos-cleanup = prev.callPackage ../packages/nixos-cleanup { };

      nix-index-update =
        let
          inherit (pkgs) coreutils wget;
        in
        prev.writeShellScriptBin "nix-index-update" ''
          readonly filename="index-${system}"
          readonly dest_dir="$HOME/.cache/nix-index"

          trap "popd >/dev/null" EXIT
          ${coreutils}/bin/mkdir -p "$dest_dir"
          pushd "$dest_dir" >/dev/null

          # -N will only download a new version if there is an update.
          ${wget}/bin/wget -q -N "https://github.com/Mic92/nix-index-database/releases/latest/download/$filename"
          ${coreutils}/bin/ln -f "$filename" files
        '';

      # TODO: on 21.11, use programs.htop.package instead
      htop = prev.htop.overrideAttrs (oldAttrs: rec {
        pname = "htop-vim";
        version = self.inputs.htop-vim.shortRev;
        src = self.inputs.htop-vim;
      });

      # TODO: remove it from 21.11
      pamixer = final.unstable.pamixer;
      rar = final.unstable.rar;
    })
  ];
}
