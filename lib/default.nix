{ nixpkgs, ... }@inputs:

# lib should avoid depending on pkgs
import ./attrsets.nix { inherit (nixpkgs) lib; } //
import ./utils.nix { inherit (nixpkgs) lib; } //
import ./nixgl.nix { inherit (nixpkgs) lib; } //
import ./flake-helpers.nix inputs
