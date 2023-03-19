{
  actions = {
    cache = "actions/cache@v3";
    checkout = "actions/checkout@v3";
    cachix-action = "cachix/cachix-action@v12";
    install-nix-action = "cachix/install-nix-action@v20";
    maximize-build-space = "easimon/maximize-build-space@v6";
    create-pull-request = "peter-evans/create-pull-request@v4";
    command-output = "mathiasvr/command-output@v2.0.0";
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
