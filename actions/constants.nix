{
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
