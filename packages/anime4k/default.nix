{ fetchzip }:
let
  modversion = "4.0";
  version = "${modversion}.1";
in
fetchzip {
  url = "https://github.com/bloc97/Anime4K/releases/download/v${version}/Anime4K_v${modversion}.zip";
  hash = "sha256-9B6U+KEVlhUIIOrDauIN3aVUjZ/gQHjFArS4uf/BpaM=";
  stripRoot = false;
}
