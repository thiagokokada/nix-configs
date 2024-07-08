{
  actions = {
    cachix-action = "cachix/cachix-action@v14";
    checkout = "actions/checkout@v4";
    create-pull-request = "peter-evans/create-pull-request@v6";
    free-disk-space = "jlumbroso/free-disk-space@v1.3.1";
    install-nix-action = "cachix/install-nix-action@v26";
  };
  ubuntu.runs-on = "ubuntu-latest";
  macos.runs-on = "macos-latest";
  home-manager = {
    linux.hostnames = [
      "home-linux"
      "steamdeck"
    ];
    darwin.hostnames = [ "home-macos" ];
  };
  nixos.hostnames = [
    "hachune-nixos"
    "miku-nixos"
    "mirai-nixos"
    "sankyuu-nixos"
  ];
}
