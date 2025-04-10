{
  experimental-features = [
    "nix-command"
    "flakes"
  ];

  substituters = [
    "https://nix-community.cachix.org"
    "https://thiagokokada-nix-configs.cachix.org"
  ];

  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "thiagokokada-nix-configs.cachix.org-1:MwFfYIvEHsVOvUPSEpvJ3mA69z/NnY6LQqIQJFvNwOc="
  ];

  max-jobs = "auto";
}
