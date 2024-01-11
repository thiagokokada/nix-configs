{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, wayland
, withNativeLibs ? false
}:

rustPlatform.buildRustPackage {
  pname = "wl-clipboard-rs";
  version = "0.8.0-unstable-2023-11-27";

  src = fetchFromGitHub {
    owner = "YaLTeR";
    repo = "wl-clipboard-rs";
    rev = "be851408e0f91edffdc2f1a76805035847f9f8a9";
    hash = "sha256-OfLn7izG1KSUjdd2gO4aaSCDlcaWoFiFmgwwhR1hRsQ=";
  };

  cargoHash = "sha256-BK+Jn2bABpOObOcTEqbnNVjMfvrEN89HZx20K+jpBBY=";

  cargoBuildFlags = [
    "--package=wl-clipboard-rs"
    "--package=wl-clipboard-rs-tools"
  ] ++ lib.optionals withNativeLibs [
    "--features=native_lib"
  ];

  nativeBuildInputs = lib.optionals withNativeLibs [
    pkg-config
  ];

  buildInputs = lib.optionals withNativeLibs [
    wayland
  ];

  preCheck = ''
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  # Assertion errors
  checkFlags = [
    "--skip=tests::copy::copy_large"
    "--skip=tests::copy::copy_multi_no_additional_text_mime_types_test"
    "--skip=tests::copy::copy_multi_test"
    "--skip=tests::copy::copy_randomized"
    "--skip=tests::copy::copy_test"
  ];

  meta = {
    description = "Command-line copy/paste utilities for Wayland, written in Rust";
    homepage = "https://github.com/YaLTeR/wl-clipboard-rs";
    # TODO: add `${version}` once we switch to tagged release
    changelog = "https://github.com/YaLTeR/wl-clipboard-rs/blob/master/CHANGELOG.md";
    inherit (wayland.meta) platforms;
    license = with lib.licenses; [ asl20 mit ];
    mainProgram = "wl-clip";
    maintainers = with lib.maintainers; [ thiagokokada ];
  };
}
