{ wgInterface, ... }:
{
  # Generate with `wg-generate-config` script
  networking.wireguard.interfaces.${wgInterface}.peers = [
    (import ./mitab5.nix)
    (import ./pixel6.nix)
    (import ./s20.nix)
    (import ./tabs8.nix)
  ];
}
