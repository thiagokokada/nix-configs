{ buildGoModule }:

buildGoModule {
  pname = "hyprtabs";
  version = "0.0.1";

  src = ./.;

  vendorHash = "sha256-fO9UpFtFZMa4m84XuKyCO5r+7gt7N9om21cVwjAibQw=";

  ldflags = [
    "-s"
    "-w"
  ];

  # No tests
  doCheck = false;

  meta.mainProgram = "hyprtabs";
}
