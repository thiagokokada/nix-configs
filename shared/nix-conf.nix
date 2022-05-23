{
  experimental-features = [ "nix-command" "flakes" ];
  auto-optimise-store = true;
  # Useful for nix-direnv, however not sure if this will
  # generate too much garbage
  # keep-outputs = true;
  # keep-derivations = true;

  # cachix
  extra-substituters = [
    "https://nix-community.cachix.org"
    "https://thiagokokada-nix-configs.cachix.org"
  ];
  extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "thiagokokada-nix-configs.cachix.org-1:MwFfYIvEHsVOvUPSEpvJ3mA69z/NnY6LQqIQJFvNwOc="
  ];
}
