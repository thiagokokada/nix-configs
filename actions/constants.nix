{
  actions = {
    cachix-action = "cachix/cachix-action@v12";
    checkout = "actions/checkout@v4";
    command-output = "mathiasvr/command-output@v2.0.0";
    create-pull-request = "peter-evans/create-pull-request@v5";
    free-disk-space = "jlumbroso/free-disk-space@v1.3.1";
    install-nix-action = "cachix/install-nix-action@v22";
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
    "mirai-nixos"
    "sankyuu-nixos"
  ];
}
