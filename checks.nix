{ pkgs }:

{
  check-nix-files = pkgs.runCommand "check-nix-files"
    {
      src = ./.;
      nativeBuildInputs = with pkgs; [ nixpkgs-fmt statix ];
    } ''
    touch $out
    cd $src
    nixpkgs-fmt --check .
    statix check
  '';
}
