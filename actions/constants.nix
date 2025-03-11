{
  actions = {
    # https://github.com/marketplace/actions/cachix
    cachix-action = "cachix/cachix-action@v15";
    # https://github.com/marketplace/actions/checkout
    checkout = "actions/checkout@v4";
    # https://github.com/marketplace/actions/create-pull-request
    create-pull-request = "peter-evans/create-pull-request@v7";
    # https://github.com/marketplace/actions/free-disk-space-ubuntu
    free-disk-space = "thiagokokada/free-disk-space@main";
    # https://github.com/marketplace/actions/install-nix
    install-nix-action = "cachix/install-nix-action@v30";
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
  nix-darwin.hostnames = [ "Sekai-MacBook-Pro" ];
  nixos.hostnames = [
    "hachune-nixos"
    "miku-nixos"
    "sankyuu-nixos"
  ];
}
