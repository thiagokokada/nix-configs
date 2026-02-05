{ nixpkgs, ... }:

let
  inherit (nixpkgs) lib;
in
{
  # Higher priority than mkForce
  mkLocalForce = lib.mkOverride 45;
  # Higher priority than mkOptionDefault, lower than mkDefault
  mkLocalOptionDefault = lib.mkOverride 1450;
}
