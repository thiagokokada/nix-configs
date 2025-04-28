{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.darwin.remapKeys;
in
{
  options.home-manager.darwin.remapKeys = {
    # https://gist.github.com/paultheman/808be117d447c490a29d6405975d41bd
    mappings = lib.mkOption {
      description = "Remap keyboard keys (requires sudo).";
      type = with lib.types; attrsOf str;
      default = { };
      example = {
        # '§±' <-> '`~'
        "0x700000035" = "0x700000064";
        "0x700000064" = "0x700000035";
      };
    };
    productID = lib.mkOption {
      description = "Product ID to remap (use `hidutil list` to get all of them).";
      type = lib.types.str;
      # Apple Internal Keyboard / Trackpad
      default = "0x0";
    };
    vendorID = lib.mkOption {
      description = "Vendor ID to remap (use `hidutil list` to get all of them).";
      type = lib.types.str;
      # Apple
      default = "0x0";
    };
  };

  config = lib.mkIf (cfg.mappings != { }) {
    home.activation.remapKeys =
      lib.hm.dag.entryAfter [ "writeBoundary" ] # bash
        ''
          source="${
            pkgs.replaceVars ./remap-keys.plist {
              inherit (cfg) productID vendorID;
              remappings = lib.pipe cfg.mappings [
                (lib.mapAttrsToList (
                  src: dst: # json
                  ''{"HIDKeyboardModifierMappingSrc": ${src}, "HIDKeyboardModifierMappingDst": ${dst}}''
                ))
                (lib.concatStringsSep ", ")
              ];
            }
          }"
          destination="${config.home.homeDirectory}/Library/LaunchAgents/com.nix.remapkeys.${cfg.vendorID}-${cfg.productID}.plist"
          if [[ ! -f "$destination" ]] || ! ${lib.getExe' pkgs.diffutils "diff"} "$source" "$destination"; then
            run ${lib.getExe' pkgs.coreutils "install"} -m644 -D "$source" "$destination"
            run /bin/launchctl load -w "$destination"
          fi
        '';
  };
}
