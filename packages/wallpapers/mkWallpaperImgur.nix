# Based on: https://github.com/Misterio77/nix-config/blob/a1b9f1706bd0f9e18b90191bfca4eddcd3f070a8/pkgs/wallpapers/wallpaper.nix
{ lib
, stdenvNoCC
, fetchurl
}:
{ name
, ext
, id
, sha256
}:

stdenvNoCC.mkDerivation {
  name = "wallpaper-${name}.${ext}";
  src = fetchurl {
    inherit sha256;
    url = "https://i.imgur.com/${id}.${ext}";
  };
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm0644 $src $out

    runHook postInstall
  '';

  meta.license = lib.licenses.unfree;
}
