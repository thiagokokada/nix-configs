{ callPackage }:

let
  mkWallpaperImgur = callPackage (import ./mkWallpaperImgur.nix) { };
in
{
  witch-hat-atelier_coco = mkWallpaperImgur {
    name = "witch-hat-atelier_coco";
    ext = "jpg";
    id = "gU5QcCD";
    sha256 = "sha256-BbT+Xp+Pn1W28tkV8mX580lAeaf6BJHBT5ojEXmywCM=";
  };
}
