{ callPackage, fetchurl, lib }:

let
  mkWallpaperImgur = callPackage (import ./mkWallpaperImgur.nix) { };
in
{
  hatsune-miku_stylized-ultrawide = mkWallpaperImgur {
    name = "hatsune-miku_stylized-ultrawide";
    id = "IMi5dxN";
    sha256 = "sha256-9lOLxW6CmTjLHBDZPW3QYqBJEsTuv6yHodnprCUVYIM=";
  };

  hatsune-miku_walking-4k = mkWallpaperImgur {
    name = "hatsune-miku_walking-4k";
    id = "CpFAG3V";
    sha256 = "sha256-aasxZ9r2Iv3uQKOscMtUIih2cHz1K3b8OfBQW4E585k=";
  };

  hatsune-miku_starry-sky = mkWallpaperImgur {
    name = "hatsune-miku_starry-sky";
    id = "f1WpcId";
    sha256 = "sha256-iHQVryAwuOVttJZN60STmJ7+Qavyz7fntR9lcPk/E6I=";
  };

  witch-hat-atelier_coco = mkWallpaperImgur {
    name = "witch-hat-atelier_coco";
    id = "gU5QcCD";
    sha256 = "sha256-BbT+Xp+Pn1W28tkV8mX580lAeaf6BJHBT5ojEXmywCM=";
  };
}
