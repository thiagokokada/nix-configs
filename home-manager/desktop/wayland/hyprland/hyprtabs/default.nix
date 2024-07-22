{ buildGoModule }:

buildGoModule {
  pname = "hyprtabs";
  version = "0.0.1";

  src = ./.;

  vendorHash = "sha256-/aCudsxC5CwDvij+JPKDJDMKtTtCiTCT3QR9dNEQAyo=";

  ldflags = [
    "-s"
    "-w"
  ];

  # No tests
  doCheck = false;

  meta.mainProgram = "hyprtabs";
}
