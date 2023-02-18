{
  actions = {
    checkout = "actions/checkout@v3";
    cachix-action = "cachix/cachix-action@v12";
    install-nix-action = "cachix/install-nix-action@v19";
    maximize-build-space = "easimon/maximize-build-space@v6";
  };
  ubuntu.runs-on = "ubuntu-latest";
  macos.runs-on = "macos-latest";
  home-manager = {
    linux.hostnames = [
      "home-linux"
      "steamdeck"
    ];
    darwin.hostnames = [
      "home-macos"
    ];
  };
  nixos.hostnames = [
    "miku-nixos"
    "mikudayo-re-nixos"
    "mirai-vps"
  ];
  nix-darwin.hostnames = [
    "miku-macos-vm"
  ];
}
