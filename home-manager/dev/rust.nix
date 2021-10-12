{ config, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
in
{
  home = {
    packages = with pkgs; [ rustup ];
    sessionPath = [ "${homeDirectory}/.cargo/bin" ];
  };
}
