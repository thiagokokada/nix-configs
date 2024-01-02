{ pkgs, lib, ... }:

import ./attrsets.nix { inherit lib; } //
import ./utils.nix { inherit lib; } //
import ./nixgl.nix { inherit pkgs lib; }
