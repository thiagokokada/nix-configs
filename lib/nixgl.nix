{ lib, ... }:

{
  nixGLWrapper =
    pkgs:
    { pkg
    , nixGL ? pkgs.nixgl.nixGLMesa
    }:
    pkgs.symlinkJoin {
      inherit (pkg) meta;

      name = "nixGL-${lib.getName pkg}";
      paths = [ pkg ];

      nativeBuildInputs = with pkgs; [ makeWrapper ];

      passthru.unwrapped = pkg;

      postBuild = ''
        mkdir -p $out/share/nixgl
        # Delete lines that start with exec
        cat '${lib.getExe nixGL}' | sed '/^exec/d' > $out/share/nixgl/env

        (
          # Prevent loop from running if no files
          shopt -s nullglob

          # Wrap programs in nixGL by loading the nixGL environment variables
          for bin in "$out/bin/"*; do
            wrapProgram "$bin" --run ". $out/share/nixgl/env"
          done

          # Fix desktop entries to point to the new binaries, if needed
          for desktop in "$out/share/applications/"*".desktop"; do
            sed -i "s|${pkg}|$out|g" "$desktop"
          done
        )
      '';
    };
}
