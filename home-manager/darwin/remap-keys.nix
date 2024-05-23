{ config, lib, pkgs, ... }:

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
      default = "0x343";
    };
    vendorID = lib.mkOption {
      description = "Vendor ID to remap (use `hidutil list` to get all of them).";
      type = lib.types.str;
      # Apple
      default = "0x5ac";
    };
  };

  config = lib.mkIf (cfg.mappings != { }) {
    home.activation.remapKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] /* bash */ ''
      source="${pkgs.substituteAll {
        inherit (cfg) productID vendorID;
        src = ./remap-keys.plist;
        remappings = lib.pipe cfg.mappings [
          (lib.mapAttrsToList
            (src: dst: /* json */
              ''{"HIDKeyboardModifierMappingSrc": ${src}, "HIDKeyboardModifierMappingDst": ${dst}}''))
          (lib.concatStringsSep ", ")
        ];
      }}"
      destination="/Library/LaunchDaemons/com.nix.remapkeys.${cfg.vendorID}-${cfg.productID}.plist"
      if ! ${lib.getExe' pkgs.diffutils "diff"} "$source" "$destination"; then
        $DRY_RUN_CMD /usr/bin/sudo ${lib.getExe' pkgs.coreutils "install"} -m644 "$source" "$destination"
        $DRY_RUN_CMD /usr/bin/sudo /bin/launchctl load -w "$destination"
      fi
    '';
  };
}
