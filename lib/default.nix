{ lib, ... }:

import ./attrsets.nix { inherit lib; } //
import ./modules.nix { inherit lib; }
