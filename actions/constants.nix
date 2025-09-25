{
  actions = {
    # https://github.com/marketplace/actions/cachix
    cachix-action = "cachix/cachix-action@v16";
    # https://github.com/marketplace/actions/checkout
    checkout = "actions/checkout@v5";
    # https://github.com/marketplace/actions/create-pull-request
    create-pull-request = "peter-evans/create-pull-request@v7";
    # https://github.com/marketplace/actions/free-disk-space-ubuntu
    free-disk-space = "thiagokokada/free-disk-space@main";
    # https://github.com/marketplace/actions/the-determinate-nix-installer
    install-nix-action = "DeterminateSystems/nix-installer-action@v20";
  };

  ubuntu.runs-on = "ubuntu-latest";
  ubuntu-arm.runs-on = "ubuntu-24.04-arm";
  macos.runs-on = "macos-latest";

  home-manager = {
    x86_64-linux.hostNames = [
      "home-linux"
      "steamdeck"
    ];
    aarch64-linux.hostNames = [ "penguin" ];
    aarch64-darwin.hostNames = [ "home-macos" ];
  };

  nix-darwin.aarch64-darwin.hostNames = [ "Sekai-MacBook-Pro" ];

  nixos = {
    aarch64-linux.hostNames = [
      "zatsune-nixos"
    ];
    x86_64-linux.hostNames = [
      "blackrockshooter-nixos"
      "hachune-nixos"
      "sankyuu-nixos"
      "zachune-nixos"
    ];
  };
}
