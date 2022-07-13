{
  NixOS.hostnames = [
    "miku-nixos"
    "mikudayo-re-nixos"
    "mirai-vps"
  ];
  HomeManager = {
    linux.hostnames = [ "home-linux" ];
    macos.hostnames = [ "home-macos" ];
  };
  NixDarwin.hostnames = [ "miku-macos-vm" ];
  ubuntu.runs-on = "ubuntu-latest";
  macos.runs-on = "macos-latest";
}
