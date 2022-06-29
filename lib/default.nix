{ pkgs, lib, ... }:

import ./attrsets.nix { inherit lib; } //
import ./shell.nix { inherit pkgs lib; }
