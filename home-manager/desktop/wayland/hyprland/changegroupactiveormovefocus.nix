{
  lib,
  buildGoModule,
  hyprland,
}:

buildGoModule {
  pname = "changegroupactiveormovefocus";
  version = "0.0.1";

  src = ./.;

  postPatch = ''
    substituteInPlace changegroupactiveormovefocus.go \
      --replace-fail hyprctl ${lib.getExe' hyprland "hyprctl"}
  '';

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta.mainProgram = "changegroupactiveormovefocus";
}
