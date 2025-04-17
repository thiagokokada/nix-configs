let
  flake = import ../flake.nix;
in
{
  inherit (flake.nixConfig) extra-substituters extra-trusted-public-keys;

  experimental-features = [
    "nix-command"
    "flakes"
  ];

  max-jobs = "auto";
}
