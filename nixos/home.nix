{ config, lib, pkgs, inputs, system, ... }:

let inherit (config.my) username;
in {
  home-manager.useUserPackages = true;
  # home-manager.useGlobalPkgs = true;
  home-manager.users.${username} =
    import ../home-manager/home.nix { inherit inputs system; };
}
