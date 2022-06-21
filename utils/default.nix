{ pkgs, ... }:

import ./pure.nix { } //
import ./shell.nix { inherit pkgs; }
