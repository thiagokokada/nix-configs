{ lib, ... }:

import ./attrsets.nix { inherit lib; } //
import ./modules.nix { inherit lib; } //
import ./utils.nix { inherit lib; }
