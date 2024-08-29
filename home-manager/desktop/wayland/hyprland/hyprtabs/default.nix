{ buildGoModule }:

buildGoModule {
  pname = "hyprtabs";
  version = "0.0.1";

  src = ./.;

  vendorHash = "sha256-85T7A/mSWnv51p8lUe07rZgQ4HWY48+H1iyMRdZLgOQ=";

  ldflags = [
    "-s"
    "-w"
  ];

  # No tests
  doCheck = false;

  meta.mainProgram = "hyprtabs";
}
