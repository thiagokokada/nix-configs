{ buildGoModule }:

buildGoModule {
  pname = "hyprtabs";
  version = "0.0.1";

  src = ./.;

  vendorHash = "sha256-vMKHN84/dypVbjyRQBzhWhhqCPenR+FSjvKGeDf+kM4=";

  ldflags = [
    "-s"
    "-w"
  ];

  # No tests
  doCheck = false;

  meta.mainProgram = "hyprtabs";
}
