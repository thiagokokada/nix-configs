{
  auto-optimise-store = true;
  trusted-users = [ "root" "@wheel" ];
  experimental-features = [ "nix-command" "flakes" "impure-derivations" "ca-derivations" ];
  # Useful for nix-direnv, however not sure if this will
  # generate too much garbage
  # keep-outputs = true;
  # keep-derivations = true;
}
