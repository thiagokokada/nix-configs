{ pkgs, ... }:


let
  nixpkgs-review =
    if (pkgs.stdenv.isLinux) then
      pkgs.nixpkgs-review.override { withSandboxSupport = true; withNom = true; }
    else
      pkgs.nixpkgs-review.override { withNon = true; };
in
{
  home.packages = with pkgs; [
    nix-output-monitor
    nixpkgs-review
  ];
}
