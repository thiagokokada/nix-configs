{
  experimental-features = [ "nix-command" "flakes" ];
  auto-optimise-store = true;
  # Useful for nix-direnv, however not sure if this will
  # generate too much garbage
  # keep-outputs = true;
  # keep-derivations = true;
}
