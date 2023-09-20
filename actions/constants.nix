{
  actions = {
    checkout = "actions/checkout@v4";
    cachix-action = "cachix/cachix-action@v12";
    install-nix-action = "cachix/install-nix-action@v22";
    maximize-build-space = "easimon/maximize-build-space@v7";
    create-pull-request = "peter-evans/create-pull-request@v5";
    command-output = "mathiasvr/command-output@v2.0.0";
    tailscale = "tailscale/github-action@v2";
  };
  ubuntu.runs-on = "ubuntu-latest";
  macos.runs-on = "macos-13";
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
    "hachune-nixos"
    "miku-nixos"
    "mirai-vps"
    "sankyuu-nixos"
    "zatsune-nixos"
  ];
}
