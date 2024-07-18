{ lib, ... }:

rec {
  shortPathWithSep =
    with lib.strings;
    (sep: path: concatStringsSep sep (map (substring 0 1) (splitString "/" path)));

  shortPath = shortPathWithSep "/";
}
