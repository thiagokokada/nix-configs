{ buildGoModule }:

buildGoModule {
  pname = "hyprtabs";
  version = "0.0.1";

  src = ./.;

  vendorHash = "sha256-QMKNajk7KguDM8xA9lCMTyYoMdEaIaoLtAjMNKBse4Y=";

  ldflags = [
    "-s"
    "-w"
  ];

  # No tests
  doCheck = false;

  meta.mainProgram = "hyprtabs";
}
