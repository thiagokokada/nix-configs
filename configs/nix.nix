(import ../flake.nix).nixConfig
// {
  experimental-features = [
    "nix-command"
    "flakes"
  ];

  max-jobs = "auto";
}
