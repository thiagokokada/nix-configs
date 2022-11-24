{
  nix.settings = {
    substituters = [ "https://thiagokokada-nix-configs.cachix.org" ];
    trusted-public-keys = [
      "thiagokokada-nix-configs.cachix.org-1:MwFfYIvEHsVOvUPSEpvJ3mA69z/NnY6LQqIQJFvNwOc="
    ];
  };
}
