{
  lib,
  buildGoModule,
  hyprland,
}:

buildGoModule {
  pname = "hyprtabs";
  version = "0.0.1";

  src = ./.;

  postPatch = ''
    substituteInPlace hyprtabs.go \
      --replace-fail hyprctl ${lib.getExe' hyprland "hyprctl"}
  '';

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta.mainProgram = "hyprtabs";
}
